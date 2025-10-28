package com.reservas;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletRequest;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.LineSeparator;

/**
 * ✅ Servlet que genera reportes de reservas en formato PDF o Excel.
 */
@WebServlet("/ReporteExportServlet")
public class ReporteExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo"); // pdf o excel
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();

        try (Connection con = ConexionDB.getConnection()) {

            String filtroFecha = "";
            if (fechaInicio != null && !fechaInicio.isEmpty() &&
                fechaFin != null && !fechaFin.isEmpty()) {
                filtroFecha = " WHERE r.fecha BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') ";
            }

            // ===============================
            // 🔹 Reservas por estado
            // ===============================
            String sqlEstado = "SELECT r.estado, COUNT(*) AS total FROM reservas r "
                    + filtroFecha
                    + " GROUP BY r.estado ORDER BY r.estado";

            try (PreparedStatement ps1 = con.prepareStatement(sqlEstado)) {
                if (!filtroFecha.isEmpty()) {
                    ps1.setString(1, fechaInicio);
                    ps1.setString(2, fechaFin);
                }
                ResultSet rs1 = ps1.executeQuery();
                while (rs1.next()) {
                    reservasPorEstado.put(rs1.getString("estado"), rs1.getInt("total"));
                }
            }

            // ===============================
            // 🔹 Reservas por recurso
            // ===============================
            String sqlRecurso = "SELECT rc.nombre AS recurso, COUNT(*) AS total "
                    + "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id "
                    + (filtroFecha.isEmpty() ? "" :
                       " WHERE r.fecha BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') ")
                    + " GROUP BY rc.nombre ORDER BY total DESC";

            try (PreparedStatement ps2 = con.prepareStatement(sqlRecurso)) {
                if (!filtroFecha.isEmpty()) {
                    ps2.setString(1, fechaInicio);
                    ps2.setString(2, fechaFin);
                }
                ResultSet rs2 = ps2.executeQuery();
                while (rs2.next()) {
                    reservasPorRecurso.put(rs2.getString("recurso"), rs2.getInt("total"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al generar el reporte de reservas.", e);
        }

        // 🔹 Exportar según el tipo solicitado
        if ("excel".equalsIgnoreCase(tipo)) {
            exportarExcel(reservasPorEstado, reservasPorRecurso, response);
        } else if ("pdf".equalsIgnoreCase(tipo)) {
            exportarPDF(reservasPorEstado, reservasPorRecurso, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de exportación inválido");
        }
    }

    // =====================================================================
    // 🟢 EXPORTAR EXCEL
    // =====================================================================
    private void exportarExcel(Map<String, Integer> reservasPorEstado,
                               Map<String, Integer> reservasPorRecurso,
                               HttpServletResponse response) throws IOException {

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.xlsx");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {

            // Estilo de encabezado
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // ===============================
            // 📘 Hoja 1: Reservas por Estado
            // ===============================
            Sheet sheet1 = workbook.createSheet("Por Estado");
            int rowNum = 0;
            Row header1 = sheet1.createRow(rowNum++);
            Cell c1 = header1.createCell(0);
            c1.setCellValue("Estado");
            c1.setCellStyle(headerStyle);

            Cell c2 = header1.createCell(1);
            c2.setCellValue("Total");
            c2.setCellStyle(headerStyle);

            for (Map.Entry<String, Integer> entry : reservasPorEstado.entrySet()) {
                Row row = sheet1.createRow(rowNum++);
                row.createCell(0).setCellValue(entry.getKey());
                row.createCell(1).setCellValue(entry.getValue());
            }

            sheet1.autoSizeColumn(0);
            sheet1.autoSizeColumn(1);

            // ===============================
            // 📘 Hoja 2: Reservas por Recurso
            // ===============================
            Sheet sheet2 = workbook.createSheet("Por Recurso");
            int rowNum2 = 0;
            Row header2 = sheet2.createRow(rowNum2++);
            Cell c3 = header2.createCell(0);
            c3.setCellValue("Recurso");
            c3.setCellStyle(headerStyle);

            Cell c4 = header2.createCell(1);
            c4.setCellValue("Total");
            c4.setCellStyle(headerStyle);

            for (Map.Entry<String, Integer> entry : reservasPorRecurso.entrySet()) {
                Row row = sheet2.createRow(rowNum2++);
                row.createCell(0).setCellValue(entry.getKey());
                row.createCell(1).setCellValue(entry.getValue());
            }

            sheet2.autoSizeColumn(0);
            sheet2.autoSizeColumn(1);

            workbook.write(out);
        }
    }

    // =====================================================================
    // 🟢 EXPORTAR PDF
    // =====================================================================
    private void exportarPDF(Map<String, Integer> reservasPorEstado,
                             Map<String, Integer> reservasPorRecurso,
                             HttpServletResponse response) throws IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.pdf");

        Document document = new Document();

        try (OutputStream out = response.getOutputStream()) {
            PdfWriter.getInstance(document, out);
            document.open();

            // ✅ Encabezado principal
            Paragraph titulo = new Paragraph("Reporte General de Reservas",
                    new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 16, com.itextpdf.text.Font.BOLD));
            titulo.setAlignment(Element.ALIGN_CENTER);
            document.add(titulo);
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Fecha de generación: " + new java.util.Date()));
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph(" "));

            // ======================================
            // 📊 SECCIÓN 1: Reservas por Estado
            // ======================================
            document.add(new Paragraph("📌 Reservas por Estado",
                    new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 13, com.itextpdf.text.Font.BOLD)));

            PdfPTable table1 = new PdfPTable(2);
            table1.setWidthPercentage(100);
            table1.addCell(new PdfPCell(new Phrase("Estado")));
            table1.addCell(new PdfPCell(new Phrase("Total")));

            if (reservasPorEstado != null && !reservasPorEstado.isEmpty()) {
                for (Map.Entry<String, Integer> entry : reservasPorEstado.entrySet()) {
                    table1.addCell(entry.getKey());
                    table1.addCell(String.valueOf(entry.getValue()));
                }
            } else {
                PdfPCell empty = new PdfPCell(new Phrase("Sin datos disponibles"));
                empty.setColspan(2);
                empty.setHorizontalAlignment(Element.ALIGN_CENTER);
                table1.addCell(empty);
            }
            document.add(table1);
            document.add(new Paragraph(" "));

            // ======================================
            // 📊 SECCIÓN 2: Reservas por Recurso
            // ======================================
            document.add(new Paragraph("📌 Reservas por Recurso",
                    new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 13, com.itextpdf.text.Font.BOLD)));

            PdfPTable table2 = new PdfPTable(2);
            table2.setWidthPercentage(100);
            table2.addCell(new PdfPCell(new Phrase("Recurso")));
            table2.addCell(new PdfPCell(new Phrase("Total")));

            if (reservasPorRecurso != null && !reservasPorRecurso.isEmpty()) {
                for (Map.Entry<String, Integer> entry : reservasPorRecurso.entrySet()) {
                    table2.addCell(entry.getKey());
                    table2.addCell(String.valueOf(entry.getValue()));
                }
            } else {
                PdfPCell empty = new PdfPCell(new Phrase("Sin datos disponibles"));
                empty.setColspan(2);
                empty.setHorizontalAlignment(Element.ALIGN_CENTER);
                table2.addCell(empty);
            }

            document.add(table2);
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Generado automáticamente por SistemaReserva",
                    new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 9, com.itextpdf.text.Font.ITALIC)));

            document.close();
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            throw new IOException("Error generando PDF: " + e.getMessage());
        }
    }
}
