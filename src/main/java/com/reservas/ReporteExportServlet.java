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

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

/**
 * ✅ Servlet que genera reportes de reservas (PDF / Excel)
 * Adaptado a PostgreSQL
 */
@WebServlet("/ReporteExportServlet")
public class ReporteExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Tipo solicitado
        String tipo = request.getParameter("tipo"); // pdf o excel

        // Filtros
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();

        try (Connection con = ConexionDB.getConnection()) {

            // =============================================
            // 🔹 Armado dinámico de WHERE (solo si hay fechas)
            // =============================================
            boolean filtrar = fechaInicio != null && !fechaInicio.isEmpty()
                           && fechaFin != null && !fechaFin.isEmpty();

            String filtroFecha = filtrar ? " WHERE r.fecha BETWEEN ? AND ? " : "";

            // ======================================================
            // 🔵 CONSULTA 1: Reservas por Estado
            // ======================================================
            String sqlEstado =
                "SELECT r.estado, COUNT(*) AS total " +
                "FROM reservas r " +
                filtroFecha +
                "GROUP BY r.estado ORDER BY r.estado";

            try (PreparedStatement ps = con.prepareStatement(sqlEstado)) {

                if (filtrar) {
                    ps.setString(1, fechaInicio);
                    ps.setString(2, fechaFin);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorEstado.put(
                        rs.getString("estado"),
                        rs.getInt("total")
                    );
                }
            }

            // ======================================================
            // 🔵 CONSULTA 2: Reservas por Recurso
            // ======================================================
            String sqlRecurso =
                "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                "FROM reservas r " +
                "JOIN recursos rc ON r.recurso_id = rc.id " +
                (filtrar ? " WHERE r.fecha BETWEEN ? AND ? " : "") +
                "GROUP BY rc.nombre ORDER BY total DESC";

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso)) {

                if (filtrar) {
                    ps.setString(1, fechaInicio);
                    ps.setString(2, fechaFin);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(
                        rs.getString("recurso"),
                        rs.getInt("total")
                    );
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al generar datos de reporte.", e);
        }

        // =============================================
        // 🟢 Exportar según el tipo solicitado
        // =============================================
        if ("excel".equalsIgnoreCase(tipo)) {
            exportarExcel(reservasPorEstado, reservasPorRecurso, response);

        } else if ("pdf".equalsIgnoreCase(tipo)) {
            exportarPDF(reservasPorEstado, reservasPorRecurso, response);

        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de exportación inválido");
        }
    }


    // ============================================================
    // 🟦 EXPORTAR EXCEL (IText + Apache POI)
    // ============================================================
    private void exportarExcel(Map<String, Integer> reservasPorEstado,
                               Map<String, Integer> reservasPorRecurso,
                               HttpServletResponse response) throws IOException {

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.xlsx");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {

            // Estilo encabezado
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // ===========================
            // 🟩 Hoja 1: Estado
            // ===========================
            Sheet sheet1 = workbook.createSheet("Por Estado");
            int r = 0;

            Row h1 = sheet1.createRow(r++);
            h1.createCell(0).setCellValue("Estado");
            h1.createCell(1).setCellValue("Total");
            h1.getCell(0).setCellStyle(headerStyle);
            h1.getCell(1).setCellStyle(headerStyle);

            for (var entry : reservasPorEstado.entrySet()) {
                Row row = sheet1.createRow(r++);
                row.createCell(0).setCellValue(entry.getKey());
                row.createCell(1).setCellValue(entry.getValue());
            }

            sheet1.autoSizeColumn(0);
            sheet1.autoSizeColumn(1);

            // ===========================
            // 🟩 Hoja 2: Recurso
            // ===========================
            Sheet sheet2 = workbook.createSheet("Por Recurso");
            int r2 = 0;

            Row h2 = sheet2.createRow(r2++);
            h2.createCell(0).setCellValue("Recurso");
            h2.createCell(1).setCellValue("Total");
            h2.getCell(0).setCellStyle(headerStyle);
            h2.getCell(1).setCellStyle(headerStyle);

            for (var entry : reservasPorRecurso.entrySet()) {
                Row row = sheet2.createRow(r2++);
                row.createCell(0).setCellValue(entry.getKey());
                row.createCell(1).setCellValue(entry.getValue());
            }

            sheet2.autoSizeColumn(0);
            sheet2.autoSizeColumn(1);

            workbook.write(out);
        }
    }


    // ============================================================
    // 🟥 EXPORTAR PDF (IText)
    // ============================================================
    private void exportarPDF(Map<String, Integer> reservasPorEstado,
                             Map<String, Integer> reservasPorRecurso,
                             HttpServletResponse response) throws IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.pdf");

        Document document = new Document();

        try (OutputStream out = response.getOutputStream()) {

            PdfWriter.getInstance(document, out);
            document.open();

            // Encabezado
            Paragraph titulo = new Paragraph("Reporte General de Reservas",
                    new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD));
            titulo.setAlignment(Element.ALIGN_CENTER);
            document.add(titulo);
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Fecha de generación: " + new java.util.Date()));
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph(" "));

            // ===============================
            // 📌 TABLA 1: Estado
            // ===============================
            document.add(new Paragraph("📌 Reservas por Estado",
                    new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD)));

            PdfPTable t1 = new PdfPTable(2);
            t1.setWidthPercentage(100);
            t1.addCell("Estado");
            t1.addCell("Total");

            if (reservasPorEstado.isEmpty()) {
                PdfPCell empty = new PdfPCell(new Phrase("No hay datos"));
                empty.setColspan(2);
                empty.setHorizontalAlignment(Element.ALIGN_CENTER);
                t1.addCell(empty);
            } else {
                for (var entry : reservasPorEstado.entrySet()) {
                    t1.addCell(entry.getKey());
                    t1.addCell(entry.getValue().toString());
                }
            }

            document.add(t1);
            document.add(new Paragraph(" "));

            // ===============================
            // 📌 TABLA 2: Recurso
            // ===============================
            document.add(new Paragraph("📌 Reservas por Recurso",
                    new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD)));

            PdfPTable t2 = new PdfPTable(2);
            t2.setWidthPercentage(100);
            t2.addCell("Recurso");
            t2.addCell("Total");

            if (reservasPorRecurso.isEmpty()) {
                PdfPCell empty = new PdfPCell(new Phrase("No hay datos"));
                empty.setColspan(2);
                empty.setHorizontalAlignment(Element.ALIGN_CENTER);
                t2.addCell(empty);
            } else {
                for (var entry : reservasPorRecurso.entrySet()) {
                    t2.addCell(entry.getKey());
                    t2.addCell(entry.getValue().toString());
                }
            }

            document.add(t2);
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph("Generado automáticamente por SistemaReserva",
                    new Font(Font.FontFamily.HELVETICA, 9, Font.ITALIC)));

            document.close();
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            throw new IOException("❌ Error al generar PDF: " + e.getMessage());
        }
    }
}
