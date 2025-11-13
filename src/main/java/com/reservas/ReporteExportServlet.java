package com.reservas;

import java.io.IOException;
import java.io.OutputStream;
import java.awt.Color;
import java.awt.BasicStroke;
import java.awt.image.BufferedImage;
import java.awt.Font; // ✔ SOLO usado por JFreeChart, ya no afecta Excel

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

// Excel (Apache POI)
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

// PDF iText
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.LineSeparator;

// Gráficos (JFreeChart)
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PiePlot;
import org.jfree.data.general.DefaultPieDataset;

import javax.imageio.ImageIO;

@WebServlet("/ReporteExportServlet")
public class ReporteExportServlet extends HttpServlet {

    private static final Color COLOR_CORPORATIVO = new Color(0, 72, 43); // #00482B

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipoEspacio = request.getParameter("tipoEspacio");
        String estadoRecurso = request.getParameter("estadoRecurso");

        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();

        try (Connection con = ConexionDB.getConnection()) {

            boolean filtrarFecha = fechaInicio != null && !fechaInicio.isEmpty()
                    && fechaFin != null && !fechaFin.isEmpty();

            // Traducir ACTIVO / INACTIVO
            String estadoBD = null;
            if ("ACTIVO".equalsIgnoreCase(estadoRecurso)) estadoBD = "DISPONIBLE";
            if ("INACTIVO".equalsIgnoreCase(estadoRecurso)) estadoBD = "OCUPADO";

            // ------------------------------
            // RESERVAS POR ESTADO
            // ------------------------------
            StringBuilder sqlEstado = new StringBuilder(
                "SELECT r.estado, COUNT(*) AS total FROM reservas r WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlEstado.append(" AND r.fecha BETWEEN CAST(? AS DATE) AND CAST(? AS DATE) ");

            sqlEstado.append(" GROUP BY r.estado ORDER BY r.estado ");

            try (PreparedStatement ps = con.prepareStatement(sqlEstado.toString())) {

                int i = 1;
                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorEstado.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // ------------------------------
            // RESERVAS POR RECURSO
            // ------------------------------
            StringBuilder sqlRecurso = new StringBuilder(
                "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlRecurso.append(" AND r.fecha BETWEEN CAST(? AS DATE) AND CAST(? AS DATE) ");

            if (tipoEspacio != null && !tipoEspacio.isEmpty())
                sqlRecurso.append(" AND rc.tipo = ? ");

            if (estadoBD != null)
                sqlRecurso.append(" AND rc.estado = ? ");

            sqlRecurso.append(" GROUP BY rc.nombre ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso.toString())) {

                int i = 1;

                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }

                if (tipoEspacio != null && !tipoEspacio.isEmpty()) {
                    ps.setString(i++, tipoEspacio);
                }

                if (estadoBD != null) {
                    ps.setString(i++, estadoBD);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(rs.getString("recurso"), rs.getInt("total"));
                }
            }

        } catch (Exception e) {
            throw new ServletException("Error generando datos", e);
        }

        // ------------------------------
        // EXPORTACIÓN
        // ------------------------------
        if ("excel".equalsIgnoreCase(tipo)) {
            exportarExcel(reservasPorEstado, reservasPorRecurso, response);

        } else if ("pdf".equalsIgnoreCase(tipo)) {
            exportarPDF(reservasPorEstado, reservasPorRecurso, response);

        } else {
            response.sendError(400, "Tipo inválido");
        }
    }

    // ============================================================
    // EXPORTAR EXCEL
    // ============================================================
    private void exportarExcel(Map<String, Integer> reservasPorEstado,
                               Map<String, Integer> reservasPorRecurso,
                               HttpServletResponse response) throws IOException {

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.xlsx");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {

            // ✔ USAR EL FONT DE APACHE POI — NO java.awt.Font
            CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 12);
            headerStyle.setFont(headerFont);

            // HOJA 1
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

            // HOJA 2
            Sheet sheet2 = workbook.createSheet("Por Recurso");
            rowIdx = 0;

            Row h2 = sheet2.createRow(rowIdx++);
            h2.createCell(0).setCellValue("Recurso");
            h2.getCell(0).setCellStyle(headerStyle);
            h2.createCell(1).setCellValue("Total");
            h2.getCell(1).setCellStyle(headerStyle);

            for (Map.Entry<String, Integer> entry : reservasPorRecurso.entrySet()) {
                Row r = sheet2.createRow(rowIdx++);
                r.createCell(0).setCellValue(entry.getKey());
                r.createCell(1).setCellValue(entry.getValue());
            }

            sheet2.autoSizeColumn(0);
            sheet2.autoSizeColumn(1);

            workbook.write(out);
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
    // EXPORTAR PDF
    // ============================================================
    private void exportarPDF(Map<String, Integer> reservasPorEstado,
                             Map<String, Integer> reservasPorRecurso,
                             HttpServletResponse response) throws IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.pdf");

        Document document = new Document(PageSize.A4);

        try (OutputStream out = response.getOutputStream()) {

            PdfWriter writer = PdfWriter.getInstance(document, out);
            document.open();

            // PORTADA ESTILO POWER BI
            Paragraph titulo = new Paragraph("Reporte de Reservas",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20));
            titulo.setAlignment(Element.ALIGN_CENTER);

            Paragraph subtitulo = new Paragraph("Sistema ReservaEspacios",
                    FontFactory.getFont(FontFactory.HELVETICA, 12));
            subtitulo.setAlignment(Element.ALIGN_CENTER);

            Paragraph fecha = new Paragraph("Generado: " + java.time.LocalDate.now(),
                    FontFactory.getFont(FontFactory.HELVETICA, 10));
            fecha.setAlignment(Element.ALIGN_CENTER);

            LineSeparator ls = new LineSeparator();
            ls.setLineColor(new com.itextpdf.text.BaseColor(0, 72, 43));
            ls.setLineWidth(2f);

            document.add(titulo);
            document.add(subtitulo);
            document.add(fecha);
            document.add(new Paragraph(" "));
            document.add(ls);
            document.add(new Paragraph(" "));

            // TABLA ESTADO
            if (!reservasPorEstado.isEmpty()) {
                document.add(new Paragraph("Reservas por Estado",
                        FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12)));

                PdfPTable table1 = new PdfPTable(2);
                table1.setWidthPercentage(100);
                table1.addCell("Estado");
                table1.addCell("Total");

                reservasPorEstado.forEach((k, v) -> {
                    table1.addCell(k);
                    table1.addCell(String.valueOf(v));
                });

                document.add(table1);
                document.add(new Paragraph(" "));
            }

            // TABLA RECURSOS
            if (!reservasPorRecurso.isEmpty()) {
                document.add(new Paragraph("Reservas por Recurso",
                        FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12)));

                PdfPTable table2 = new PdfPTable(2);
                table2.setWidthPercentage(100);
                table2.addCell("Recurso");
                table2.addCell("Total");

                reservasPorRecurso.forEach((k, v) -> {
                    table2.addCell(k);
                    table2.addCell(String.valueOf(v));
                });

                document.add(table2);
                document.add(new Paragraph(" "));
            }

            // GRÁFICO
            if (!reservasPorEstado.isEmpty()) {
                document.add(new Paragraph("Distribución de Reservas por Estado",
                        FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12)));

                BufferedImage image = crearGrafico(reservasPorEstado);
                com.itextpdf.text.Image img = com.itextpdf.text.Image.getInstance(writer, image, 1);
                img.scaleToFit(350, 250);
                img.setAlignment(Element.ALIGN_CENTER);
                document.add(img);
            }

            document.close();

        } catch (Exception e) {
            throw new IOException("Error generando PDF", e);
        }
    }
}
