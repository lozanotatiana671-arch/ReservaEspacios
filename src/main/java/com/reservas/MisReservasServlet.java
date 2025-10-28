package com.reservas;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/MisReservasServlet")
public class MisReservasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 Validar sesión
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int usuarioId = (Integer) sesion.getAttribute("usuarioId");
        List<Reserva> reservas = new ArrayList<>();

        try (Connection con = ConexionDB.getConnection()) {

            // ✅ Actualizado: usamos hora_inicio y hora_fin en lugar de hora
            String sql = "SELECT r.id, r.nombre, TO_CHAR(r.fecha, 'YYYY-MM-DD') AS fecha, " +
                         "r.hora_inicio, r.hora_fin, r.estado, rc.nombre AS recurso_nombre " +
                         "FROM reservas r " +
                         "JOIN recursos rc ON r.recurso_id = rc.id " +
                         "WHERE r.usuario_id = ? " +
                         "ORDER BY r.fecha DESC, r.hora_inicio ASC";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, usuarioId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Reserva r = new Reserva();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));  // Usuario que hizo la reserva
                r.setFecha(rs.getString("fecha"));
                r.setHoraInicio(rs.getString("hora_inicio"));
                r.setHoraFin(rs.getString("hora_fin"));
                r.setEstado(rs.getString("estado"));
                r.setRecursoNombre(rs.getString("recurso_nombre"));
                reservas.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error al obtener las reservas del usuario", e);
        }

        // 🔹 Enviar las reservas al JSP
        request.setAttribute("reservas", reservas);
        request.getRequestDispatcher("misReservas.jsp").forward(request, response);
    }
}
