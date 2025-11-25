package com.reservas;

import java.io.IOException;
import java.sql.Date;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/DisponibilidadServlet")
public class DisponibilidadServlet extends HttpServlet {

    private ReservaDAO reservaDAO = new ReservaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int recursoId = Integer.parseInt(request.getParameter("recursoId"));
            String fechaStr = request.getParameter("fecha");
            String horaInicio = request.getParameter("horaInicio");
            String horaFin = request.getParameter("horaFin");

            Date fecha = Date.valueOf(fechaStr);

            boolean conflicto = reservaDAO.hayConflicto(recursoId, fecha, horaInicio, horaFin);
            boolean disponible = !conflicto;

            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"disponible\":" + disponible + "}");

        } catch (Exception e) {
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"disponible\":false}");
        }
    }
}
