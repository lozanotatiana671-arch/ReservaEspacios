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

// Apache POI (Excel)
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.usermodel.Font;

// iText (PDF)
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.pdf.draw.LineSeparator;

@WebServlet("/ReporteExportServlet")
public class ReporteExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();

        try (Connection con = ConexionDB.getConnection()) {

            boolean filtrar = fechaInicio != null && !fechaInicio.isEmpty()
                           && fechaFin != null && !fechaFin.isEmpty();

            String filtroFecha = filtrar ? " WHERE r.fecha BETWEEN ? AND ? " : "";

            // ----------------------------
            // RESERVAS POR ESTADO
            // ----------------------------
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
                    reservasPorEstado.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // ----------------------------
            // RESERVAS POR RECURSO
            // ----------------------------
            String sqlRecurso =
                    "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                    "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id " +
                    (filtrar ? " WHERE r.fecha BETWEEN ? AND ? " : "") +
                    "GROUP BY rc.nombre ORDER BY total DESC";

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso)) {
                if (filtrar) {
                    ps.setString(1, fechaInicio);
                    ps.setString(2, fechaFin);
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(rs.getString("recurso"), rs.getInt("total"));
                }
            }

        } catch (Exception e) {
            throw new ServletException("Error generando datos", e);
        }

        if ("excel".equalsIgnoreCase(tipo)) {
            exportarExcel(reservasPorEstado, reservasPorRecurso, response);
        } else if ("pdf".equalsIgnoreCase(tipo)) {
            exportarPDF(reservasPorEstado, reservasPorRecurso, response);
        }
    }


    // ============================================================
    // EXCEL EXPORT
    // ============================================================
    private void exportarExcel(Map<String, Integer> reservasPorEstado,
                               Map<String, Integer> reservasPorRecurso,
                               HttpServletResponse response) throws IOException {

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.xlsx");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {

            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // Página 1
            Sheet sheet1 = workbook.createSheet("Por Estado");
            int rowIdx = 0;

            Row h1 = sheet1.createRow(rowIdx++);
            h1.createCell(0).setCellValue("Estado");
            h1.getCell(0).setCellStyle(headerStyle);
            h1.createCell(1).setCellValue("Total");
            h1.getCell(1).setCellStyle(headerStyle);

            for (Map.Entry<String, Integer> entry : reservasPorEstado.entrySet()) {
                Row r = sheet1.createRow(rowIdx++);
                r.createCell(0).setCellValue(entry.getKey());
                r.createCell(1).setCellValue(entry.getValue());
            }

            sheet1.autoSizeColumn(0);
            sheet1.autoSizeColumn(1);

            // Página 2
            Sheet sheet2 = workbook.createSheet("Por Recurso");
            int rowIdx2 = 0;

            Row h2 = sheet2.createRow(rowIdx2++);
            h2.createCell(0).setCellValue("Recurso");
            h2.getCell(0).setCellStyle(headerStyle);
            h2.createCell(1).setCellValue("Total");
            h2.getCell(1).setCellStyle(headerStyle);

            for (Map.Entry<String, Integer> entry : reservasPorRecurso.entrySet()) {
                Row r = sheet2.createRow(rowIdx2++);
                r.createCell(0).setCellValue(entry.getKey());
                r.createCell(1).setCellValue(entry.getValue());
            }

            sheet2.autoSizeColumn(0);
            sheet2.autoSizeColumn(1);

            workbook.write(out);
        }
    }


    // ============================================================
    // PDF EXPORT
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

            com.itextpdf.text.Font titleFont =
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);

            Paragraph titulo = new Paragraph("Reporte de Reservas", titleFont);
            titulo.setAlignment(Element.ALIGN_CENTER);
            document.add(titulo);
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph(" "));

            // --------------------------
            // TABLA 1
            // --------------------------
            com.itextpdf.text.Font sectionFont =
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);

            document.add(new Paragraph("Reservas por Estado", sectionFont));

            PdfPTable table1 = new PdfPTable(2);
            table1.setWidthPercentage(100);
            table1.addCell("Estado");
            table1.addCell("Total");

            for (Map.Entry<String, Integer> entry : reservasPorEstado.entrySet()) {
                table1.addCell(entry.getKey());
                table1.addCell(String.valueOf(entry.getValue()));
            }

            document.add(table1);
            document.add(new Paragraph(" "));

            // --------------------------
            // TABLA 2
            // --------------------------
            document.add(new Paragraph("Reservas por Recurso", sectionFont));

            PdfPTable table2 = new PdfPTable(2);
            table2.setWidthPercentage(100);
            table2.addCell("Recurso");
            table2.addCell("Total");

            for (Map.Entry<String, Integer> entry : reservasPorRecurso.entrySet()) {
                table2.addCell(entry.getKey());
                table2.addCell(String.valueOf(entry.getValue()));
            }

            document.add(table2);
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());

            document.close();
        }
    }
}
