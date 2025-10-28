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

        String nombre = request.getParameter("nombre");
        String correo = request.getParameter("correo");
        String mensaje = request.getParameter("mensaje");

        try (Connection con = ConexionDB.getConnection()) {
            String sql = "INSERT INTO contactos (nombre, correo, mensaje) VALUES (?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, correo);
            ps.setString(3, mensaje);

            int filas = ps.executeUpdate();
            if (filas > 0) {
                request.setAttribute("mensaje", "✅ Su mensaje ha sido enviado con éxito. ¡Gracias por contactarnos!");
            } else {
                request.setAttribute("mensaje", "❌ Error al enviar el mensaje.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("mensaje", "⚠ Error: " + e.getMessage());
        }

        request.getRequestDispatcher("contactenos.jsp").forward(request, response);
    }
}
