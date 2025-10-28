package com.reservas;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/EliminarRecursoServlet")
public class EliminarRecursoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        try {
            RecursoDAO.eliminar(id);
            response.sendRedirect("ListaRecursosServlet");
        } catch (Exception e) {
            throw new ServletException("Error al eliminar recurso", e);
        }
    }
}
