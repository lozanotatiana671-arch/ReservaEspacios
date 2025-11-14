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

@WebServlet("/ReporteExportServlet")
public class ReporteExportServlet extends HttpServlet {

    private static final com.itextpdf.text.BaseColor PDF_VERDE =
            new com.itextpdf.text.BaseColor(0, 72, 43);
    private static final com.itextpdf.text.BaseColor PDF_VERDE_CLARO =
            new com.itextpdf.text.BaseColor(121, 192, 0);

    // ============================================================
    // GET → SOLO EXCEL
    // ============================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");

        if (!"excel".equalsIgnoreCase(tipo)) {
            response.sendError(405, "GET solo permite tipo=excel");
            return;
        }

        Map<String, Integer> est = new LinkedHashMap<>();
        Map<String, Integer> rec = new LinkedHashMap<>();
        Map<String, Integer> tipos = new LinkedHashMap<>();

        cargarDatos(request, est, rec, tipos);

        exportarExcel(est, rec, tipos, response);
    }

    // ============================================================
    // POST → PDF CON TABLAS + GRÁFICOS BASE64
    // ============================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");

        if (!"pdf".equalsIgnoreCase(tipo)) {
            response.sendError(405, "POST solo permite tipo=pdf");
            return;
        }

        generarPDF(request, response);
    }

    // ============================================================
    // CONSULTA SQL (COMPATIBLE CON TUS FILTROS)
    // ============================================================
    private void cargarDatos(HttpServletRequest request,
                             Map<String, Integer> est,
                             Map<String, Integer> rec,
                             Map<String, Integer> tipos) {

        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipoEspacio = request.getParameter("tipo");
        String estado = request.getParameter("estado");

        try (Connection con = ConexionDB.getConnection()) {

            boolean filtrarFecha = fechaInicio != null && !fechaInicio.isEmpty()
                                 && fechaFin != null && !fechaFin.isEmpty();

            // ================= ESTADO ==================
            StringBuilder sqlEstado = new StringBuilder(
                "SELECT estado, COUNT(*) AS total FROM reservas WHERE 1=1 ");

            if (filtrarFecha) sqlEstado.append(" AND fecha BETWEEN ? AND ? ");
            if (estado != null && !estado.isEmpty()) sqlEstado.append(" AND estado = ? ");

            sqlEstado.append(" GROUP BY estado ORDER BY estado ");

            try (PreparedStatement ps = con.prepareStatement(sqlEstado.toString())) {
                int i=1;
                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }
                if (estado!=null && !estado.isEmpty()) ps.setString(i++, estado);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    est.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // ================= RECURSO ==================
            StringBuilder sqlRecurso = new StringBuilder(
                "SELECT rc.nombre, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 ");

            if (filtrarFecha) sqlRecurso.append(" AND r.fecha BETWEEN ? AND ? ");
            if (tipoEspacio!=null && !tipoEspacio.isEmpty()) sqlRecurso.append(" AND rc.tipo = ? ");
            if (estado!=null && !estado.isEmpty()) sqlRecurso.append(" AND r.estado = ? ");

            sqlRecurso.append(" GROUP BY rc.nombre ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso.toString())) {
                int i=1;

                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }
                if (tipoEspacio!=null && !tipoEspacio.isEmpty()) ps.setString(i++, tipoEspacio);
                if (estado!=null && !estado.isEmpty()) ps.setString(i++, estado);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    rec.put(rs.getString("nombre"), rs.getInt("total"));
                }
            }

            // ================= TIPO ==================
            StringBuilder sqlTipo = new StringBuilder(
                "SELECT rc.tipo, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 ");

            if (filtrarFecha) sqlTipo.append(" AND r.fecha BETWEEN ? AND ? ");
            if (estado!=null && !estado.isEmpty()) sqlTipo.append(" AND r.estado = ? ");

            sqlTipo.append(" GROUP BY rc.tipo ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlTipo.toString())) {
                int i=1;

                if (filtrarFecha) {
                    ps.setString(i++, fechaInicio);
                    ps.setString(i++, fechaFin);
                }
                if (estado!=null && !estado.isEmpty()) ps.setString(i++, estado);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    tipos.put(rs.getString("tipo"), rs.getInt("total"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ============================================================
    // GENERAR PDF COMPLETO
    // ============================================================
    private void generarPDF(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Map<String, Integer> est = new LinkedHashMap<>();
        Map<String, Integer> rec = new LinkedHashMap<>();
        Map<String, Integer> tipos = new LinkedHashMap<>();

        cargarDatos(request, est, rec, tipos);

        response.setContentType("application/pdf");
        Document document = new Document(PageSize.A4);

        try (OutputStream out = response.getOutputStream()) {

            PdfWriter.getInstance(document, out);
            document.open();

            // ---------- PORTADA ----------
            Paragraph titulo = new Paragraph("Reporte de Reservas",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, PDF_VERDE));
            titulo.setAlignment(Element.ALIGN_CENTER);

            Paragraph sub = new Paragraph("Sistema ReservaEspacios",
                    FontFactory.getFont(FontFactory.HELVETICA, 13));
            sub.setAlignment(Element.ALIGN_CENTER);

            Paragraph fecha = new Paragraph("Generado: " + java.time.LocalDate.now(),
                    FontFactory.getFont(FontFactory.HELVETICA, 10));
            fecha.setAlignment(Element.ALIGN_CENTER);

            LineSeparator ls = new LineSeparator();
            ls.setLineWidth(2);
            ls.setLineColor(PDF_VERDE);

            document.add(titulo);
            document.add(sub);
            document.add(fecha);
            document.add(new Paragraph(" "));
            document.add(ls);
            document.add(new Paragraph(" "));

            // ---------- TABLAS ----------
            agregarTabla(document, "Reservas por Estado", est);
            agregarTabla(document, "Reservas por Recurso", rec);
            agregarTabla(document, "Reservas por Tipo", tipos);

            // ---------- GRÁFICOS BASE64 ----------
            agregarGraficoBase64(document, "Distribución por Estado", request.getParameter("imgEstado"));
            agregarGraficoBase64(document, "Cantidad por Recurso", request.getParameter("imgRecurso"));
            agregarGraficoBase64(document, "Distribución por Tipo", request.getParameter("imgTipo"));

            document.close();

        } catch (Exception e) {
            throw new IOException("Error generando PDF", e);
        }
    }

    // ============================================================
    // TABLAS (CON ESTILO CORPORATIVO)
    // ============================================================
    private void agregarTabla(Document d, String titulo, Map<String,Integer> datos) throws Exception {

        if (datos.isEmpty()) return;

        d.add(new Paragraph(titulo,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, PDF_VERDE)));

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);

        PdfPCell h1 = new PdfPCell(new Paragraph("Categoría",
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, com.itextpdf.text.BaseColor.WHITE)));
        h1.setBackgroundColor(PDF_VERDE);
        h1.setPadding(6);

        PdfPCell h2 = new PdfPCell(new Paragraph("Total",
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, com.itextpdf.text.BaseColor.WHITE)));
        h2.setBackgroundColor(PDF_VERDE);
        h2.setPadding(6);

        table.addCell(h1);
        table.addCell(h2);

        boolean alt = false;

        for (Map.Entry<String,Integer> e : datos.entrySet()) {

            com.itextpdf.text.BaseColor rowColor =
                alt ? new com.itextpdf.text.BaseColor(245,255,244) : com.itextpdf.text.BaseColor.WHITE;
            alt = !alt;

            PdfPCell c1 = new PdfPCell(new Paragraph(e.getKey()));
            c1.setPadding(5);
            c1.setBackgroundColor(rowColor);

            PdfPCell c2 = new PdfPCell(new Paragraph(String.valueOf(e.getValue())));
            c2.setPadding(5);
            c2.setBackgroundColor(rowColor);

            table.addCell(c1);
            table.addCell(c2);
        }

        d.add(table);
        d.add(new Paragraph(" "));
    }

    // ============================================================
    // GRÁFICOS BASE64 Chart.js
    // ============================================================
    private void agregarGraficoBase64(Document d, String titulo, String base64)
            throws Exception {

        if (base64 == null || base64.isEmpty()) return;

        d.add(new Paragraph(titulo,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, PDF_VERDE)));
        d.add(new Paragraph(" "));

        String limpio = base64.replace("data:image/png;base64,", "");
        byte[] bytes = java.util.Base64.getDecoder().decode(limpio);

        com.itextpdf.text.Image img = com.itextpdf.text.Image.getInstance(bytes);
        img.scaleToFit(440, 270);
        img.setAlignment(Element.ALIGN_CENTER);

        d.add(img);
        d.add(new Paragraph(" "));
    }

    // ============================================================
    // EXPORTAR EXCEL
    // ============================================================
    private void exportarExcel(Map<String,Integer> est,
                               Map<String,Integer> rec,
                               Map<String,Integer> tipos,
                               HttpServletResponse response) throws IOException {

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_reservas.xlsx");

        try (Workbook wb = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {

            CellStyle header = wb.createCellStyle();
            org.apache.poi.ss.usermodel.Font f = wb.createFont();
            f.setBold(true);
            header.setFont(f);

            crearHoja(wb, "Por Estado", est, header);
            crearHoja(wb, "Por Recurso", rec, header);
            crearHoja(wb, "Por Tipo", tipos, header);

            wb.write(out);
        }
    }

    private void crearHoja(Workbook wb, String nombre, Map<String,Integer> datos, CellStyle header) {
        Sheet sh = wb.createSheet(nombre);
        int r=0;

        Row h = sh.createRow(r++);
        h.createCell(0).setCellValue("Categoría");
        h.getCell(0).setCellStyle(header);
        h.createCell(1).setCellValue("Total");
        h.getCell(1).setCellStyle(header);

        for (Map.Entry<String,Integer> e : datos.entrySet()) {
            Row row = sh.createRow(r++);
            row.createCell(0).setCellValue(e.getKey());
            row.createCell(1).setCellValue(e.getValue());
        }

        sh.autoSizeColumn(0);
        sh.autoSizeColumn(1);
    }
}
