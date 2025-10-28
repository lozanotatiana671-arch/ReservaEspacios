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

        if (session != null && session.getAttribute("usuarioId") != null) {
            int usuarioId = (Integer) session.getAttribute("usuarioId");
            NotificacionDAO dao = new NotificacionDAO();
            List<Notificacion> notifs = dao.listarPorUsuario(usuarioId);
            int count = dao.contarNoLeidas(usuarioId);
            req.setAttribute("notificaciones", notifs);
            req.setAttribute("notificacionesCount", count);
        }

        chain.doFilter(request, response);
    }
}
