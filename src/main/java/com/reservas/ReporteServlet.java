package com.reservas;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ReporteServlet")
public class ReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 🔹 Filtros
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipo = request.getParameter("tipo");
        String estado = request.getParameter("estado");
        String capacidadStr = request.getParameter("capacidad");

        Integer capacidad = null;
        if (capacidadStr != null && !capacidadStr.isEmpty()) {
            try {
                capacidad = Integer.parseInt(capacidadStr);
            } catch (NumberFormatException e) {}
        }

        // 🔹 Mantener filtros en el JSP
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("tipo", tipo);
        request.setAttribute("estado", estado);
        request.setAttribute("capacidad", capacidadStr);

        // 🔹 Data structures
        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();
        Map<String, Integer> reservasPorUsuario = new LinkedHashMap<>();
        List<Map<String, Object>> listaRecursos = new ArrayList<>();

        try (Connection con = ConexionDB.getConnection()) {

            boolean tieneFecha = fechaInicio != null && !fechaInicio.isEmpty()
                              && fechaFin != null && !fechaFin.isEmpty();

            String filtroFecha = tieneFecha ? " WHERE r.fecha BETWEEN ? AND ? " : "";

            // =====================================================
            // 🔵 1. Reservas por Estado
            // =====================================================
            String sqlEstado =
                "SELECT r.estado, COUNT(*) AS total " +
                "FROM reservas r " +
                filtroFecha +
                "GROUP BY r.estado ORDER BY r.estado";

            try (PreparedStatement ps = con.prepareStatement(sqlEstado)) {
                if (tieneFecha) {
                    ps.setString(1, fechaInicio);
                    ps.setString(2, fechaFin);
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorEstado.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // =====================================================
            // 🔵 2. Reservas por Recurso
            // =====================================================
            String sqlRecurso =
                "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                "FROM reservas r " +
                "JOIN recursos rc ON r.recurso_id = rc.id " +
                (tieneFecha ? " WHERE r.fecha BETWEEN ? AND ? " : "") +
                "GROUP BY rc.nombre ORDER BY total DESC";

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso)) {
                if (tieneFecha) {
                    ps.setString(1, fechaInicio);
                    ps.setString(2, fechaFin);
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(rs.getString("recurso"), rs.getInt("total"));
                }
            }

            // =====================================================
            // 🔵 3. Reservas por Usuario
            // =====================================================
            String sqlUsuario =
                "SELECT u.nombre AS usuario, COUNT(*) AS total " +
                "FROM reservas r " +
                "JOIN usuarios u ON r.usuario_id = u.id " +
                (tieneFecha ? " WHERE r.fecha BETWEEN ? AND ? " : "") +
                "GROUP BY u.nombre ORDER BY total DESC";

            try (PreparedStatement ps = con.prepareStatement(sqlUsuario)) {
                if (tieneFecha) {
                    ps.setString(1, fechaInicio);
                    ps.setString(2, fechaFin);
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorUsuario.put(rs.getString("usuario"), rs.getInt("total"));
                }
            }

            // =====================================================
            // 🔵 4. LISTA DE RECURSOS (FILTROS DINÁMICOS)
            // =====================================================
            StringBuilder sqlR = new StringBuilder(
                "SELECT DISTINCT rc.nombre, rc.tipo, rc.estado, rc.capacidad, rc.tarifa, rc.ubicacion " +
                "FROM recursos rc LEFT JOIN reservas r ON rc.id = r.recurso_id WHERE 1 = 1 "
            );

            List<Object> params = new ArrayList<>();

            if (tieneFecha) {
                sqlR.append(" AND r.fecha BETWEEN ? AND ? ");
                params.add(fechaInicio);
                params.add(fechaFin);
            }

            if (tipo != null && !tipo.isEmpty()) {
                sqlR.append(" AND rc.tipo = ? ");
                params.add(tipo);
            }

            if (estado != null && !estado.isEmpty()) {
                sqlR.append(" AND rc.estado = ? ");
                params.add(estado);
            }

            if (capacidad != null) {
                sqlR.append(" AND rc.capacidad = ? ");
                params.add(capacidad);
            }

            sqlR.append(" ORDER BY rc.nombre ASC ");

            try (PreparedStatement ps = con.prepareStatement(sqlR.toString())) {

                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("nombre", rs.getString("nombre"));
                    fila.put("tipo", rs.getString("tipo"));
                    fila.put("estado", rs.getString("estado"));
                    fila.put("capacidad", rs.getInt("capacidad"));
                    fila.put("tarifa", rs.getDouble("tarifa"));
                    fila.put("ubicacion", rs.getString("ubicacion"));
                    listaRecursos.add(fila);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al generar el reporte.", e);
        }

        // =====================================================
        // 🔹 Enviar datos al JSP
        // =====================================================
        request.setAttribute("reservasPorEstado", reservasPorEstado);
        request.setAttribute("reservasPorRecurso", reservasPorRecurso);
        request.setAttribute("reservasPorUsuario", reservasPorUsuario);
        request.setAttribute("listaRecursos", listaRecursos);

        request.getRequestDispatcher("reporte.jsp").forward(request, response);
    }
}
