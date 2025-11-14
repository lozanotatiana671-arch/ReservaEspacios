package com.reservas;

import java.io.IOException;
import java.io.OutputStream;
import java.awt.Color;
import java.awt.Font;
import java.awt.image.BufferedImage;

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

// Excel
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

// PDF
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.LineSeparator;

// Gráficos JFreeChart
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PiePlot;
import org.jfree.data.general.DefaultPieDataset;

@WebServlet("/ReporteExportServlet")
public class ReporteExportServlet extends HttpServlet {

    private static final Color VERDE_OSCURO = new Color(0, 72, 43);   // #00482B
    private static final com.itextpdf.text.BaseColor PDF_VERDE = new com.itextpdf.text.BaseColor(0, 72, 43);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipoEspacio = request.getParameter("tipo");
        String estadoReserva = request.getParameter("estado");

        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();
        Map<String, Integer> reservasPorTipo = new LinkedHashMap<>();

        try (Connection con = ConexionDB.getConnection()) {

            boolean filtrarFecha = fechaInicio != null && !fechaInicio.isEmpty()
                    && fechaFin != null && !fechaFin.isEmpty();

            // ================================
            // RESERVAS POR ESTADO (filtra)
            // ================================
            StringBuilder sqlEstado = new StringBuilder(
                "SELECT r.estado, COUNT(*) AS total FROM reservas r WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlEstado.append(" AND r.fecha BETWEEN ?::date AND ?::date ");

            if (estadoReserva != null && !estadoReserva.isEmpty())
                sqlEstado.append(" AND UPPER(r.estado) = UPPER(?) ");

            sqlEstado.append(" GROUP BY r.estado ORDER BY r.estado ");

            try (PreparedStatement ps = con.prepareStatement(sqlEstado.toString())) {

                int i = 1;
                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }

                if (estadoReserva != null && !estadoReserva.isEmpty())
                    ps.setString(i++, estadoReserva);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorEstado.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // ================================
            // RESERVAS POR RECURSO (filtra)
            // ================================
            StringBuilder sqlRecurso = new StringBuilder(
                "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlRecurso.append(" AND r.fecha BETWEEN ?::date AND ?::date ");

            if (tipoEspacio != null && !tipoEspacio.isEmpty())
                sqlRecurso.append(" AND rc.tipo = ? ");

            if (estadoReserva != null && !estadoReserva.isEmpty())
                sqlRecurso.append(" AND UPPER(r.estado) = UPPER(?) ");

            sqlRecurso.append(" GROUP BY rc.nombre ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso.toString())) {

                int i = 1;

                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }

                if (tipoEspacio != null && !tipoEspacio.isEmpty())
                    ps.setString(i++, tipoEspacio);

                if (estadoReserva != null && !estadoReserva.isEmpty())
                    ps.setString(i++, estadoReserva);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(rs.getString("recurso"), rs.getInt("total"));
                }
            }

            // ================================
            // RESERVAS POR TIPO (filtra)
            // ================================
            StringBuilder sqlTipo = new StringBuilder(
                "SELECT rc.tipo AS tipo, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlTipo.append(" AND r.fecha BETWEEN ?::date AND ?::date ");

            if (estadoReserva != null && !estadoReserva.isEmpty())
                sqlTipo.append(" AND UPPER(r.estado) = UPPER(?) ");

            sqlTipo.append(" GROUP BY rc.tipo ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlTipo.toString())) {

                int i = 1;

                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }

                if (estadoReserva != null && !estadoReserva.isEmpty())
                    ps.setString(i++, estadoReserva);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorTipo.put(rs.getString("tipo"), rs.getInt("total"));
                }
            }

        } catch (Exception e) {
            throw new ServletException("Error generando datos para exportación", e);
        }

        // Exportar según tipo
        if ("excel".equalsIgnoreCase(tipo)) {
            exportarExcel(reservasPorEstado, reservasPorRecurso, reservasPorTipo, response);

        } else if ("pdf".equalsIgnoreCase(tipo)) {
            exportarPDF(reservasPorEstado, reservasPorRecurso, reservasPorTipo, response);

        } else {
            response.sendError(400, "Tipo inválido");
        }
    }

    // ============================================================
    // CREAR GRÁFICO PIE
    // ============================================================
    private BufferedImage crearGrafico(Map<String, Integer> datos) {

        DefaultPieDataset dataset = new DefaultPieDataset();
        datos.forEach(dataset::setValue);

        JFreeChart chart = ChartFactory.createPieChart("", dataset, false, false, false);
        PiePlot plot = (PiePlot) chart.getPlot();

        plot.setBackgroundPaint(Color.WHITE);
        plot.setOutlineVisible(false);
        plot.setShadowPaint(null);

        plot.setLabelFont(new Font("Arial", Font.PLAIN, 10));

        return chart.createBufferedImage(450, 300);
    }

    // ============================================================
    // EXPORTAR PDF (CON 3 GRÁFICOS)
    // ============================================================
    private void exportarPDF(Map<String, Integer> reservasPorEstado,
                             Map<String, Integer> reservasPorRecurso,
                             Map<String, Integer> reservasPorTipo,
                             HttpServletResponse response) throws IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.pdf");

        Document document = new Document(PageSize.A4);

        try (OutputStream out = response.getOutputStream()) {

            PdfWriter writer = PdfWriter.getInstance(document, out);
            document.open();

            // PORTADA
            Paragraph titulo = new Paragraph("Reporte de Reservas",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, PDF_VERDE));
            titulo.setAlignment(Element.ALIGN_CENTER);

            Paragraph subtitulo = new Paragraph("Sistema ReservaEspacios",
                    FontFactory.getFont(FontFactory.HELVETICA, 12));
            subtitulo.setAlignment(Element.ALIGN_CENTER);

            Paragraph fecha = new Paragraph("Generado: " + java.time.LocalDate.now(),
                    FontFactory.getFont(FontFactory.HELVETICA, 10));
            fecha.setAlignment(Element.ALIGN_CENTER);

            LineSeparator ls = new LineSeparator();
            ls.setLineColor(PDF_VERDE);
            ls.setLineWidth(2f);

            document.add(titulo);
            document.add(subtitulo);
            document.add(fecha);
            document.add(new Paragraph(" "));
            document.add(ls);
            document.add(new Paragraph(" "));

            // ===================================================
            // TABLAS + ESTILOS
            // ===================================================
            agregarTablaPDF(document, "Reservas por Estado", reservasPorEstado);
            agregarTablaPDF(document, "Reservas por Recurso", reservasPorRecurso);
            agregarTablaPDF(document, "Reservas por Tipo", reservasPorTipo);

            // ===================================================
            // GRÁFICOS
            // ===================================================
            agregarGraficoPDF(document, writer, "Distribución por Estado", reservasPorEstado);
            agregarGraficoPDF(document, writer, "Uso por Recurso", reservasPorRecurso);
            agregarGraficoPDF(document, writer, "Distribución por Tipo", reservasPorTipo);

            document.close();

        } catch (Exception e) {
            throw new IOException("Error generando PDF", e);
        }
    }

    // ============================================================
    // TABLAS PDF con estilo corporativo
    // ============================================================
    private void agregarTablaPDF(Document document, String titulo, Map<String, Integer> datos)
            throws Exception {

        if (datos.isEmpty()) return;

        document.add(new Paragraph(titulo,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, PDF_VERDE)));

        PdfPTable tabla = new PdfPTable(2);
        tabla.setWidthPercentage(100);

        PdfPCell h1 = new PdfPCell(new Paragraph("Categoría",
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, com.itextpdf.text.BaseColor.WHITE)));
        h1.setBackgroundColor(PDF_VERDE);
        h1.setPadding(6);

        PdfPCell h2 = new PdfPCell(new Paragraph("Total",
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, com.itextpdf.text.BaseColor.WHITE)));
        h2.setBackgroundColor(PDF_VERDE);
        h2.setPadding(6);

        tabla.addCell(h1);
        tabla.addCell(h2);

        boolean par = false;

        for (Map.Entry<String, Integer> e : datos.entrySet()) {

            com.itextpdf.text.BaseColor fondo =
                    par ? new com.itextpdf.text.BaseColor(245, 255, 244) : com.itextpdf.text.BaseColor.WHITE;
            par = !par;

            PdfPCell c1 = new PdfPCell(new Paragraph(e.getKey()));
            c1.setPadding(5);
            c1.setBackgroundColor(fondo);

            PdfPCell c2 = new PdfPCell(new Paragraph(String.valueOf(e.getValue())));
            c2.setPadding(5);
            c2.setBackgroundColor(fondo);

            tabla.addCell(c1);
            tabla.addCell(c2);
        }

        document.add(tabla);
        document.add(new Paragraph(" "));
    }

    // ============================================================
    // GRÁFICOS PDF
    // ============================================================
    private void agregarGraficoPDF(Document document, PdfWriter writer,
                                   String titulo, Map<String, Integer> datos)
            throws Exception {

        if (datos.isEmpty()) return;

        document.add(new Paragraph(titulo,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, PDF_VERDE)));

        BufferedImage img = crearGrafico(datos);
        com.itextpdf.text.Image pdfImg =
                com.itextpdf.text.Image.getInstance(writer, img, 1);

        pdfImg.scaleToFit(350, 250);
        pdfImg.setAlignment(Element.ALIGN_CENTER);

        document.add(pdfImg);
        document.add(new Paragraph(" "));
    }

    // ============================================================
    // EXPORTAR EXCEL (3 hojas)
    // ============================================================
    private void exportarExcel(Map<String, Integer> reservasPorEstado,
                               Map<String, Integer> reservasPorRecurso,
                               Map<String, Integer> reservasPorTipo,
                               HttpServletResponse response) throws IOException {

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.xlsx");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {

            CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 12);
            headerStyle.setFont(headerFont);

            crearHojaExcel(workbook, "Por Estado", reservasPorEstado, headerStyle);
            crearHojaExcel(workbook, "Por Recurso", reservasPorRecurso, headerStyle);
            crearHojaExcel(workbook, "Por Tipo", reservasPorTipo, headerStyle);

            workbook.write(out);
        }
    }

    private void crearHojaExcel(Workbook workbook, String nombre, Map<String, Integer> datos,
                                CellStyle headerStyle) {

        Sheet sheet = workbook.createSheet(nombre);
        int rowIdx = 0;

        Row h = sheet.createRow(rowIdx++);
        h.createCell(0).setCellValue("Categoría");
        h.getCell(0).setCellStyle(headerStyle);
        h.createCell(1).setCellValue("Total");
        h.getCell(1).setCellStyle(headerStyle);

        for (Map.Entry<String, Integer> e : datos.entrySet()) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(e.getKey());
            r.createCell(1).setCellValue(e.getValue());
        }

        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);
    }
}
