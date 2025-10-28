package com.reservas;

// 🔴 Cambiar los imports antiguos por los nuevos si usas Tomcat 10+
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;
import java.util.List;

@WebServlet("/ListaNotificacionesServlet") // Esto permite mapear el servlet sin usar web.xml
public class ListaNotificacionesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 Verificar sesión activa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 🔹 Obtener ID de usuario desde sesión
        int usuarioId = (int) session.getAttribute("usuarioId");

        // 🔹 Obtener notificaciones del DAO
        NotificacionDAO dao = new NotificacionDAO();
        List<Notificacion> notificaciones = dao.listarPorUsuario(usuarioId);

        // 🔹 Pasar notificaciones a la JSP
        request.setAttribute("notificaciones", notificaciones);

        // 🔹 Redirigir a la vista
        RequestDispatcher rd = request.getRequestDispatcher("listaNotificaciones.jsp");
        rd.forward(request, response);
    }
}
