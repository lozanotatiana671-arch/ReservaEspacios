package com.reservas;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/CancelarReservaServlet")
public class CancelarReservaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int usuarioId = (Integer) sesion.getAttribute("usuarioId");
        String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");
        int reservaId = Integer.parseInt(request.getParameter("id"));
        String recursoNombre = "(desconocido)";

        try (Connection con = ConexionDB.getConnection()) {

            // ✅ Obtener el recurso asociado
            String getRecurso = 
                "SELECT rc.NOMBRE AS recurso_nombre " +
                "FROM RESERVA r " +
                "JOIN RECURSO rc ON r.RECURSO_ID = rc.ID " +
                "WHERE r.ID = ? AND r.USUARIO_ID = ?";

            try (PreparedStatement ps = con.prepareStatement(getRecurso)) {
                ps.setInt(1, reservaId);
                ps.setInt(2, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        recursoNombre = rs.getString("recurso_nombre");
                    }
                }
            }

            // ✅ Actualizar el estado
            String sql = "UPDATE RESERVA SET ESTADO='Cancelado' WHERE ID=? AND USUARIO_ID=?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, reservaId);
                ps.setInt(2, usuarioId);
                ps.executeUpdate();
            }

            // ✅ Crear notificación para el admin
            Notificacion notificacion = new Notificacion();
            notificacion.setUsuarioId(1);
            notificacion.setReservaId(reservaId);
            notificacion.setMensaje("❌ El usuario " + usuarioNombre +
                    " canceló la reserva del espacio '" + recursoNombre + "'.");
            notificacion.setEstado("NUEVA");
            new NotificacionDAO().insertar(notificacion);

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
