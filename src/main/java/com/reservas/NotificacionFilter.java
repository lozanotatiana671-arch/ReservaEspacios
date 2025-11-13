package com.reservas;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

@WebFilter("/*")
public class NotificacionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession(false);

        // Solo carga notificaciones si el usuario está autenticado
        if (session != null && session.getAttribute("usuarioId") != null) {

            int usuarioId = (Integer) session.getAttribute("usuarioId");

            NotificacionDAO dao = new NotificacionDAO();
            List<Notificacion> notifs = dao.listarPorUsuario(usuarioId);
            int count = dao.contarNoLeidas(usuarioId);

            // ⬅️ LO IMPORTANTE: Volvemos a usar REQUEST (como antes)
            req.setAttribute("notificaciones", notifs);
            req.setAttribute("notificacionesCount", count);
        }

        chain.doFilter(request, response);
    }
}
