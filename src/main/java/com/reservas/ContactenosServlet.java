package com.reservas;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ContactenosServlet")
public class ContactenosServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 Obtener datos de la sesión
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int usuarioId = (int) sesion.getAttribute("usuarioId");
        String nombre = (String) sesion.getAttribute("usuarioNombre");
        String correo = (String) sesion.getAttribute("usuarioCorreo");

        // 🔹 Obtener mensaje del formulario
        String mensaje = request.getParameter("mensaje");

        try (Connection con = ConexionDB.getConnection()) {

            String sql = "INSERT INTO contactos (usuario_id, nombre, correo, mensaje) VALUES (?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, usuarioId);
            ps.setString(2, nombre);
            ps.setString(3, correo);
            ps.setString(4, mensaje);

            int filas = ps.executeUpdate();

            if (filas > 0) {
                request.setAttribute("mensaje", 
                    "✅ Su mensaje ha sido enviado con éxito. ¡Gracias por contactarnos!");
            } else {
                request.setAttribute("mensaje", 
                    "❌ No se pudo enviar el mensaje. Inténtelo nuevamente.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("mensaje", "⚠ Error inesperado: " + e.getMessage());
        }

        // 🔹 Mantener el mensaje en el JSP
        request.getRequestDispatcher("contactenos.jsp").forward(request, response);
    }
}
