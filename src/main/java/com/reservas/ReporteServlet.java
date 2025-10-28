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

        // 🔹 Parámetros del filtro
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipo = request.getParameter("tipo");
        String estado = request.getParameter("estado");
        String capacidadStr = request.getParameter("capacidad");

        Integer capacidad = null;
        try {
            if (capacidadStr != null && !capacidadStr.isEmpty()) {
                capacidad = Integer.parseInt(capacidadStr);
            }
        } catch (NumberFormatException e) {
            capacidad = null;
        }

        // 🟢 Mantener filtros activos en JSP
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("tipo", tipo);
        request.setAttribute("estado", estado);
        request.setAttribute("capacidad", capacidadStr);

        // 🟢 Estructuras de datos
        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();
        Map<String, Integer> reservasPorUsuario = new LinkedHashMap<>();
        List<Map<String, Object>> listaRecursos = new ArrayList<>();

        try (Connection con = ConexionDB.getConnection()) {

            // =====================================================
            // 🔸 1. Filtro general de fecha
            // =====================================================
            String filtroFecha = "";
            boolean tieneFecha = (fechaInicio != null && !fechaInicio.isEmpty() &&
                                  fechaFin != null && !fechaFin.isEmpty());

            if (tieneFecha) {
                filtroFecha = " WHERE r.fecha BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') ";
            }

            // =====================================================
            // 🔸 2. Reservas por estado
            // =====================================================
            String sqlEstado = "SELECT r.estado, COUNT(*) AS total " +
                               "FROM reservas r " + filtroFecha +
                               "GROUP BY r.estado ORDER BY r.estado";
            try (PreparedStatement ps1 = con.prepareStatement(sqlEstado)) {
                if (tieneFecha) {
                    ps1.setString(1, fechaInicio);
                    ps1.setString(2, fechaFin);
                }
                ResultSet rs1 = ps1.executeQuery();
                while (rs1.next()) {
                    reservasPorEstado.put(rs1.getString("estado"), rs1.getInt("total"));
                }
            }

            // =====================================================
            // 🔸 3. Reservas por recurso
            // =====================================================
            String sqlRecurso = "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id " +
                                (tieneFecha ? " WHERE r.fecha BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') " : "") +
                                "GROUP BY rc.nombre ORDER BY total DESC";
            try (PreparedStatement ps2 = con.prepareStatement(sqlRecurso)) {
                if (tieneFecha) {
                    ps2.setString(1, fechaInicio);
                    ps2.setString(2, fechaFin);
                }
                ResultSet rs2 = ps2.executeQuery();
                while (rs2.next()) {
                    reservasPorRecurso.put(rs2.getString("recurso"), rs2.getInt("total"));
                }
            }

            // =====================================================
            // 🔸 4. Reservas por usuario
            // =====================================================
            String sqlUsuario = "SELECT u.nombre AS usuario, COUNT(*) AS total " +
                                "FROM reservas r JOIN usuarios u ON r.usuario_id = u.id " +
                                (tieneFecha ? " WHERE r.fecha BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') " : "") +
                                "GROUP BY u.nombre ORDER BY total DESC";
            try (PreparedStatement ps3 = con.prepareStatement(sqlUsuario)) {
                if (tieneFecha) {
                    ps3.setString(1, fechaInicio);
                    ps3.setString(2, fechaFin);
                }
                ResultSet rs3 = ps3.executeQuery();
                while (rs3.next()) {
                    reservasPorUsuario.put(rs3.getString("usuario"), rs3.getInt("total"));
                }
            }

            // =====================================================
            // 🔸 5. Lista de recursos con filtros (INCLUYE FECHA)
            // =====================================================
            StringBuilder sqlRecursos = new StringBuilder(
                "SELECT DISTINCT rc.nombre, rc.tipo, rc.estado, rc.capacidad, rc.tarifa, rc.ubicacion " +
                "FROM recursos rc " +
                "LEFT JOIN reservas r ON rc.id = r.recurso_id WHERE 1=1 "
            );

            List<Object> params = new ArrayList<>();

            // Fechas
            if (tieneFecha) {
                sqlRecursos.append("AND r.fecha BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') ");
                params.add(fechaInicio);
                params.add(fechaFin);
            }

            // Tipo
            if (tipo != null && !tipo.isEmpty()) {
                sqlRecursos.append("AND rc.tipo = ? ");
                params.add(tipo);
            }

            // Estado
            if (estado != null && !estado.isEmpty()) {
                sqlRecursos.append("AND rc.estado = ? ");
                params.add(estado);
            }

            // Capacidad
            if (capacidad != null) {
                sqlRecursos.append("AND rc.capacidad = ? ");
                params.add(capacidad);
            }

            sqlRecursos.append("ORDER BY rc.nombre ASC");

            try (PreparedStatement ps4 = con.prepareStatement(sqlRecursos.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps4.setObject(i + 1, params.get(i));
                }

                ResultSet rs4 = ps4.executeQuery();
                while (rs4.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("nombre", rs4.getString("nombre"));
                    fila.put("tipo", rs4.getString("tipo"));
                    fila.put("estado", rs4.getString("estado"));
                    fila.put("capacidad", rs4.getInt("capacidad"));
                    fila.put("tarifa", rs4.getDouble("tarifa"));
                    fila.put("ubicacion", rs4.getString("ubicacion"));
                    listaRecursos.add(fila);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al generar el reporte de reservas.", e);
        }

        // 🟢 Enviar datos al JSP
        request.setAttribute("reservasPorEstado", reservasPorEstado);
        request.setAttribute("reservasPorRecurso", reservasPorRecurso);
        request.setAttribute("reservasPorUsuario", reservasPorUsuario);
        request.setAttribute("listaRecursos", listaRecursos);

        // 🔹 Redirigir al JSP
        request.getRequestDispatcher("reporte.jsp").forward(request, response);
    }
}
