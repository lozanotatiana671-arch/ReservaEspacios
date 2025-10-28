package com.reservas;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");

        try (Connection con = ConexionDB.getConnection()) {
            // Traemos también correo y teléfono 👇
            String sql = "SELECT id, nombre, correo, telefono, rol FROM usuarios WHERE correo=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, correo);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Usuario encontrado
                HttpSession session = request.getSession();
                session.setAttribute("usuarioId", rs.getInt("id"));
                session.setAttribute("usuarioNombre", rs.getString("nombre"));
                session.setAttribute("usuarioCorreo", rs.getString("correo"));   // 👈 nuevo
                session.setAttribute("usuarioTelefono", rs.getString("telefono")); // 👈 nuevo
                session.setAttribute("usuarioRol", rs.getString("rol"));

                // Redirigir según rol
                if ("ADMIN".equalsIgnoreCase(rs.getString("rol"))) {
    response.sendRedirect(request.getContextPath() + "/ListaReservasServlet");
} else {
    response.sendRedirect(request.getContextPath() + "/perfilUsuario.jsp");
}

            } else {
                // Usuario no encontrado
                request.setAttribute("mensaje", "Correo o contraseña incorrectos.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("mensaje", "Error en el inicio de sesión.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
