package com.reservas;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/CambiarEstadoServlet")
public class CambiarEstadoServlet extends HttpServlet {

    private ReservaDAO dao = new ReservaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String nuevoEstado = request.getParameter("estado");

        // 1️⃣ Cambiar estado
        dao.cambiarEstado(id, nuevoEstado);

        // 2️⃣ Buscar usuario dueño de la reserva
        int usuarioId = -1;
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT usuario_id FROM reservas WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    usuarioId = rs.getInt("usuario_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3️⃣ Enviar notificación
        if (usuarioId > 0) {
            Notificacion n = new Notificacion();
            n.setReservaId(id);
            n.setUsuarioId(usuarioId);
            n.setMensaje("Tu reserva #" + id + " cambió a estado: " + nuevoEstado);
            n.setEstado("NUEVA");
            new NotificacionDAO().insertar(n);
        }

        // 4️⃣ Redirigir
        response.sendRedirect("ListaReservasServlet");
    }
}
