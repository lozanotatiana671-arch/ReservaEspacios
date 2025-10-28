package com.reservas;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/NotificacionServlet")
public class NotificacionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        NotificacionDAO dao = new NotificacionDAO();
        HttpSession session = req.getSession(false);

        if ("marcarLeida".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            dao.marcarLeida(id);
            resp.sendRedirect(req.getHeader("referer")); // vuelve a la página anterior
            return;
        }

        if ("marcarTodas".equals(action)) {
            if (session != null && session.getAttribute("usuarioId") != null) {
                int usuarioId = (Integer) session.getAttribute("usuarioId");
                dao.marcarTodasLeidas(usuarioId);
            }
            resp.sendRedirect(req.getHeader("referer"));
            return;
        }

        // default
        resp.sendRedirect(req.getHeader("referer"));
    }
}
