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

        // ------------------------------
        // Filtros
        // ------------------------------
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String tipoEspacio = request.getParameter("tipo");     // ✔ el JSP usa name="tipo"
        String estadoRecurso = request.getParameter("estado"); // ✔ el JSP usa name="estado"

        // Mantener filtros en JSP
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("tipo", tipoEspacio);
        request.setAttribute("estado", estadoRecurso);

        // ------------------------------
        // Estructuras de datos
        // ------------------------------
        Map<String, Integer> reservasPorEstado = new LinkedHashMap<>();
        Map<String, Integer> reservasPorRecurso = new LinkedHashMap<>();
        Map<String, Integer> reservasPorTipo = new LinkedHashMap<>(); // ✔ NECESARIA PARA LA GRÁFICA
        Map<String, Integer> reservasPorUsuario = new LinkedHashMap<>();
        List<Map<String, Object>> listaRecursos = new ArrayList<>();

        try (Connection con = ConexionDB.getConnection()) {

            boolean tieneFecha = fechaInicio != null && !fechaInicio.isEmpty()
                    && fechaFin != null && !fechaFin.isEmpty();

            // Convertir ACTIVO / INACTIVO → DISPONIBLE / OCUPADO
            String estadoBD = null;
            if ("ACTIVO".equalsIgnoreCase(estadoRecurso)) estadoBD = "DISPONIBLE";
            if ("INACTIVO".equalsIgnoreCase(estadoRecurso)) estadoBD = "OCUPADO";

            // =====================================================
            // 1. RESERVAS POR ESTADO
            // =====================================================
            StringBuilder sqlEstado = new StringBuilder(
                "SELECT r.estado, COUNT(*) AS total FROM reservas r WHERE 1=1 "
            );

            if (tieneFecha)
                sqlEstado.append(" AND r.fecha BETWEEN CAST(? AS DATE) AND CAST(? AS DATE) ");

            sqlEstado.append(" GROUP BY r.estado ORDER BY r.estado ");

            try (PreparedStatement ps = con.prepareStatement(sqlEstado.toString())) {

                int idx = 1;
                if (tieneFecha) {
                    ps.setString(idx++, fechaInicio);
                    ps.setString(idx++, fechaFin);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorEstado.put(rs.getString("estado"), rs.getInt("total"));
                }
            }

            // =====================================================
            // 2. RESERVAS POR RECURSO
            // =====================================================
            StringBuilder sqlRecurso = new StringBuilder(
                "SELECT rc.nombre AS recurso, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 "
            );

            if (tieneFecha)
                sqlRecurso.append(" AND r.fecha BETWEEN CAST(? AS DATE) AND CAST(? AS DATE) ");

            if (tipoEspacio != null && !tipoEspacio.isEmpty())
                sqlRecurso.append(" AND rc.tipo = ? ");

            if (estadoBD != null)
                sqlRecurso.append(" AND rc.estado = ? ");

            sqlRecurso.append(" GROUP BY rc.nombre ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlRecurso.toString())) {

                int idx = 1;

                if (tieneFecha) {
                    ps.setString(idx++, fechaInicio);
                    ps.setString(idx++, fechaFin);
                }

                if (tipoEspacio != null && !tipoEspacio.isEmpty()) {
                    ps.setString(idx++, tipoEspacio);
                }

                if (estadoBD != null) {
                    ps.setString(idx++, estadoBD);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorRecurso.put(rs.getString("recurso"), rs.getInt("total"));
                }
            }

            // =====================================================
            // 3. RESERVAS POR TIPO DE ESPACIO (✔ NUEVA, FALTABA)
            // =====================================================
            StringBuilder sqlTipo = new StringBuilder(
                "SELECT rc.tipo AS tipo, COUNT(*) AS total " +
                "FROM reservas r JOIN recursos rc ON r.recurso_id = rc.id WHERE 1=1 "
            );

            if (tieneFecha)
                sqlTipo.append(" AND r.fecha BETWEEN CAST(? AS DATE) AND CAST(? AS DATE) ");

            sqlTipo.append(" GROUP BY rc.tipo ORDER BY total DESC ");

            try (PreparedStatement ps = con.prepareStatement(sqlTipo.toString())) {

                int idx = 1;

                if (tieneFecha) {
                    ps.setString(idx++, fechaInicio);
                    ps.setString(idx++, fechaFin);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    reservasPorTipo.put(rs.getString("tipo"), rs.getInt("total"));
                }
            }

            // =====================================================
            // 4. TABLA DE RECURSOS FILTRADA
            // =====================================================
            StringBuilder sqlR = new StringBuilder(
                "SELECT rc.nombre, rc.tipo, rc.estado, rc.capacidad, rc.tarifa, rc.ubicacion " +
                "FROM recursos rc WHERE 1=1 "
            );

            List<Object> params = new ArrayList<>();

            if (tipoEspacio != null && !tipoEspacio.isEmpty()) {
                sqlR.append(" AND rc.tipo = ? ");
                params.add(tipoEspacio);
            }

            if (estadoBD != null) {
                sqlR.append(" AND rc.estado = ? ");
                params.add(estadoBD);
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
            throw new ServletException("Error al generar el reporte.", e);
        }

        // ------------------------------
        // Enviar al JSP
        // ------------------------------
        request.setAttribute("reservasPorEstado", reservasPorEstado);
        request.setAttribute("reservasPorRecurso", reservasPorRecurso);
        request.setAttribute("reservasPorTipo", reservasPorTipo);  // ✔ AHORA SÍ SE ENVÍA
        request.setAttribute("reservasPorUsuario", reservasPorUsuario);
        request.setAttribute("listaRecursos", listaRecursos);

        request.getRequestDispatcher("reporte.jsp").forward(request, response);
    }
}
