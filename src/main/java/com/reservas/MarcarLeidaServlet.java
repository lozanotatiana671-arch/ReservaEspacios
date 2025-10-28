package com.reservas;

// Cambia estos imports antiguos:
// import javax.servlet.*;
// import javax.servlet.http.*;

// Usa los nuevos:
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;

@WebServlet("/MarcarLeidaServlet")
public class MarcarLeidaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            NotificacionDAO dao = new NotificacionDAO();
            dao.marcarLeida(id);
        }

        response.sendRedirect("ListaNotificacionesServlet");
    }
}
