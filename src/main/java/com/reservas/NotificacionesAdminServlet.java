package com.reservas;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/NotificacionesAdminServlet")
public class NotificacionesAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioRol") == null ||
            !"admin".equalsIgnoreCase((String) sesion.getAttribute("usuarioRol"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        NotificacionDAO dao = new NotificacionDAO();

        // 🔹 El administrador verá TODAS las notificaciones (no solo las suyas)
        List<Notificacion> notificaciones = dao.listarPorUsuario(1); // ID del admin (puedes ajustar)
        int nuevas = dao.contarNoLeidas(1);

        request.setAttribute("notificaciones", notificaciones);
        request.setAttribute("notificacionesCount", nuevas);

        // 🔹 Ir a la vista JSP (admin-notificaciones.jsp)
        request.getRequestDispatcher("admin-notificaciones.jsp").forward(request, response);
    }
}
