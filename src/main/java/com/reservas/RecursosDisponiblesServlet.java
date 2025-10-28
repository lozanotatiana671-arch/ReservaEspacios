package com.reservas;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/RecursosDisponiblesServlet")
public class RecursosDisponiblesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fecha = request.getParameter("fecha"); // Formato: YYYY-MM-DD
        String hora = request.getParameter("hora");   // Formato: HH:mm

        List<Recurso> recursos = new ArrayList<>();
        Map<Integer, Boolean> disponibilidad = new HashMap<>();

        try (Connection con = ConexionDB.getConnection()) {

            // 1️⃣ Obtener todos los recursos
            String sqlRecursos = "SELECT id, nombre, descripcion, tipo, estado FROM recursos ORDER BY nombre";
            try (PreparedStatement ps = con.prepareStatement(sqlRecursos);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Recurso r = new Recurso();
                    r.setId(rs.getInt("id"));
                    r.setNombre(rs.getString("nombre"));
                    r.setDescripcion(rs.getString("descripcion"));
                    r.setTipo(rs.getString("tipo"));
                    r.setEstado(rs.getString("estado"));
                    recursos.add(r);
                }
            }

            // 2️⃣ Calcular disponibilidad si hay fecha y hora
            if (fecha != null && hora != null && !fecha.isEmpty() && !hora.isEmpty()) {

                // Convertir hora a minutos
                String[] parts = hora.split(":");
                int horaMin = Integer.parseInt(parts[0]) * 60 + Integer.parseInt(parts[1]);

                // SQL para obtener recursos ocupados
                String sqlDisp = 
                    "SELECT recurso_id FROM (" +
                    "  SELECT r.recurso_id, " +
                    "         TO_NUMBER(SUBSTR(r.hora,1,2))*60 + TO_NUMBER(SUBSTR(r.hora,4,2)) AS minutos, " +
                    "         UPPER(r.estado) AS estado_upper " +
                    "  FROM reservas r " +
                    "  WHERE r.fecha = TO_DATE(?, 'YYYY-MM-DD')" +
                    ") " +
                    "WHERE estado_upper IN ('APROBADO','PRESTADO') " +
                    "  AND minutos BETWEEN ? AND ?";

                Set<Integer> recursosNoDisponibles = new HashSet<>();
                try (PreparedStatement ps = con.prepareStatement(sqlDisp)) {
                    ps.setString(1, fecha);
                    ps.setInt(2, horaMin - 120); // 2 horas antes
                    ps.setInt(3, horaMin + 120); // 2 horas después

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            recursosNoDisponibles.add(rs.getInt("recurso_id"));
                        }
                    }
                }

                // Llenar mapa de disponibilidad
                for (Recurso r : recursos) {
                    disponibilidad.put(r.getId(), !recursosNoDisponibles.contains(r.getId()));
                }

            } else {
                // Sin fecha/hora: todos disponibles
                for (Recurso r : recursos) {
                    disponibilidad.put(r.getId(), true);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error al consultar recursos", e);
        }

        // Pasar datos al JSP
        request.setAttribute("fecha", fecha);
        request.setAttribute("hora", hora);
        request.setAttribute("recursos", recursos);
        request.setAttribute("disponibilidad", disponibilidad);

        request.getRequestDispatcher("recursosDisponibles.jsp").forward(request, response);
    }
}
