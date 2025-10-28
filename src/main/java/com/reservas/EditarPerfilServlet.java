package com.reservas;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/EditarPerfilServlet")
public class EditarPerfilServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String nombre = request.getParameter("nombre");
        String correo = request.getParameter("correo");
        String telefono = request.getParameter("telefono");
        String password = request.getParameter("password");

        HttpSession sesion = request.getSession(false);
        String rol = (sesion != null && sesion.getAttribute("usuarioRol") != null)
                        ? (String) sesion.getAttribute("usuarioRol") : "usuario";

        try (Connection con = ConexionDB.getConnection()) {
            String sql;
            PreparedStatement ps;

            if (password != null && !password.isEmpty()) {
                sql = "UPDATE usuarios SET nombre=?, correo=?, telefono=?, password=? WHERE id=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setString(3, telefono);
                ps.setString(4, password);
                ps.setInt(5, id);
            } else {
                sql = "UPDATE usuarios SET nombre=?, correo=?, telefono=? WHERE id=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setString(3, telefono);
                ps.setInt(4, id);
            }

            int filas = ps.executeUpdate();
            if (filas > 0) {
                // ✅ Actualizar sesión
                if (sesion != null) {
                    sesion.setAttribute("usuarioNombre", nombre);
                    sesion.setAttribute("usuarioCorreo", correo);
                    sesion.setAttribute("usuarioTelefono", telefono);
                }

                // 🔹 Redirigir según rol
                if ("admin".equalsIgnoreCase(rol)) {
                    response.sendRedirect("ListaReservasServlet?msg=Perfil actualizado correctamente");
                } else {
                    response.sendRedirect("perfilUsuario.jsp?msg=Perfil actualizado correctamente");
                }
            } else {
                request.setAttribute("mensaje", "Error: no se pudo actualizar el perfil.");
                if ("admin".equalsIgnoreCase(rol)) {
                    request.getRequestDispatcher("configuracion.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("editarPerfil.jsp").forward(request, response);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("mensaje", "Error en la actualización: " + e.getMessage());
            if ("admin".equalsIgnoreCase(rol)) {
                request.getRequestDispatcher("configuracion.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("editarPerfil.jsp").forward(request, response);
            }
        }
    }
}
