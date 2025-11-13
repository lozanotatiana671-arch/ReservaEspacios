package com.reservas;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ConsultaServlet")
public class ConsultaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect("contactenos.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 Validar que el usuario esté autenticado
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Datos desde la sesión
        int usuarioId = (int) sesion.getAttribute("usuarioId");
        String nombre = (String) sesion.getAttribute("usuarioNombre");
        String correo = (String) sesion.getAttribute("usuarioCorreo");

        // Mensaje desde el formulario
        String mensaje = request.getParameter("mensaje");

        // Crear objeto consulta
        Consulta c = new Consulta();
        c.setUsuarioId(usuarioId);
        c.setNombre(nombre);
        c.setCorreo(correo);
        c.setMensaje(mensaje);

        // Guardar en BD
        ConsultaDAO dao = new ConsultaDAO();
        boolean ok = dao.registrar(c);

        if (ok) {
            request.setAttribute("mensaje", "✅ Tu consulta fue enviada con éxito.");
        } else {
            request.setAttribute("mensaje", "❌ Error al enviar la consulta.");
        }

        request.getRequestDispatcher("contactenos.jsp").forward(request, response);
    }
}
