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

        // Filtros EXACTOS DEL JSP
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipoEspacio = request.getParameter("tipo");
        String estadoReserva = request.getParameter("estado"); // Aprobada, Finalizado...

        // Normalizar estado
        if (estadoReserva != null && !estadoReserva.isEmpty()) {
            estadoReserva = estadoReserva.toUpperCase().trim();
        }

        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("tipo", tipoEspacio);
        request.setAttribute("estado", estadoReserva);

        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();
        Map<String, Integer> reservasPorTipo = new LinkedHashMap<>();
        List<Map<String, Object>> listaRecursos = new ArrayList<>();

        try (Connection con = ConexionDB.getConnection()) {

            boolean filtrarFecha = fechaInicio != null && !fechaInicio.isEmpty()
                    && fechaFin != null && !fechaFin.isEmpty();

            // ============================
            // 1. DISTRIBUCIÓN POR ESTADO
            // FILTRA POR ESTADO
            // ============================
            StringBuilder sqlEstado = new StringBuilder(
                "SELECT r.estado, COUNT(*) AS total FROM reservas r WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlEstado.append(" AND r.fecha BETWEEN ?::date AND ?::date ");

            if (estadoReserva != null && !estadoReserva.isEmpty())
                sqlEstado.append(" AND UPPER(r.estado) = ? ");

            sqlEstado.append(" GROUP BY r.estado ORDER BY r.estado ");

            try (PreparedStatement ps = con.prepareStatement(sqlEstado.toString())) {

                int idx = 1;

                if (filtrarFecha) {
                    ps.setDate(idx++, java.sql.Date.valueOf(fechaInicio));
                    ps.setDate(idx++, java.sql.Date.valueOf(fechaFin));
                }

                if (estadoReserva != null && !estadoReserva.isEmpty())
                    ps.setString(idx++, estadoReserva);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorEstado.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // ============================
            // 2. CANTIDAD POR RECURSO
            // ============================
            StringBuilder sqlRecurso = new StringBuilder(
                "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id " +
                "WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlRecurso.append(" AND r.fecha BETWEEN ?::date AND ?::date ");

            if (tipoEspacio != null && !tipoEspacio.isEmpty())
                sqlRecurso.append(" AND rc.tipo = ? ");

            if (estadoReserva != null && !estadoReserva.isEmpty())
                sqlRecurso.append(" AND UPPER(r.estado) = ? ");

            sqlRecurso.append(" GROUP BY rc.nombre ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso.toString())) {

                int idx = 1;

                if (filtrarFecha) {
                    ps.setDate(idx++, java.sql.Date.valueOf(fechaInicio));
                    ps.setDate(idx++, java.sql.Date.valueOf(fechaFin));
                }

                if (tipoEspacio != null && !tipoEspacio.isEmpty())
                    ps.setString(idx++, tipoEspacio);

                if (estadoReserva != null && !estadoReserva.isEmpty())
                    ps.setString(idx++, estadoReserva);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(rs.getString("recurso"), rs.getInt("total"));
                }
            }

            // ============================
            // 3. DISTRIBUCIÓN POR TIPO
            // ============================
            StringBuilder sqlTipo = new StringBuilder(
                "SELECT rc.tipo AS tipo, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id " +
                "WHERE 1=1 "
            );

            if (filtrarFecha)
                sqlTipo.append(" AND r.fecha BETWEEN ?::date AND ?::date ");

            if (estadoReserva != null && !estadoReserva.isEmpty())
                sqlTipo.append(" AND UPPER(r.estado) = ? ");

            sqlTipo.append(" GROUP BY rc.tipo ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlTipo.toString())) {

                int idx = 1;

                if (filtrarFecha) {
                    ps.setDate(idx++, java.sql.Date.valueOf(fechaInicio));
                    ps.setDate(idx++, java.sql.Date.valueOf(fechaFin));
                }

                if (estadoReserva != null && !estadoReserva.isEmpty())
                    ps.setString(idx++, estadoReserva);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorTipo.put(rs.getString("tipo"), rs.getInt("total"));
                }
            }

            // ============================
            // 4. TABLA DE RECURSOS
            // ============================
            StringBuilder sqlRecursos = new StringBuilder(
                "SELECT rc.nombre, rc.tipo, rc.estado, rc.capacidad, rc.tarifa, rc.ubicacion " +
                "FROM recursos rc WHERE 1=1 "
            );

            if (tipoEspacio != null && !tipoEspacio.isEmpty()) {
                sqlRecursos.append(" AND rc.tipo = ? ");
            }

            sqlRecursos.append(" ORDER BY rc.nombre ASC ");

            try (PreparedStatement ps = con.prepareStatement(sqlRecursos.toString())) {

                int idx = 1;

                if (tipoEspacio != null && !tipoEspacio.isEmpty()) {
                    ps.setString(idx++, tipoEspacio);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> fila = new HashMap<>();
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
            throw new ServletException("Error al generar el reporte.", e);
        }

        request.setAttribute("reservasPorEstado", reservasPorEstado);
        request.setAttribute("reservasPorRecurso", reservasPorRecurso);
        request.setAttribute("reservasPorTipo", reservasPorTipo);
        request.setAttribute("listaRecursos", listaRecursos);

        request.getRequestDispatcher("reporte.jsp").forward(request, response);
    }
}
