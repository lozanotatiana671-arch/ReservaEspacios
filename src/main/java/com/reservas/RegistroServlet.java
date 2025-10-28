package com.reservas;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/registro")
public class RegistroServlet extends HttpServlet {
    private UsuarioDAO dao = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario u = new Usuario();
        u.setNombre(request.getParameter("nombre"));
        u.setIdentificacion(request.getParameter("identificacion"));
        u.setCorreo(request.getParameter("correo"));
        u.setTelefono(request.getParameter("telefono"));
        u.setPassword(request.getParameter("password")); // luego encriptamos
        u.setRol("USER");

        boolean exito = dao.registrar(u);

        if (exito) {
            request.setAttribute("mensaje", "Usuario registrado con éxito. Ahora puede iniciar sesión.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("mensaje", "Error al registrar usuario. Intente nuevamente.");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
        }
    }
}
