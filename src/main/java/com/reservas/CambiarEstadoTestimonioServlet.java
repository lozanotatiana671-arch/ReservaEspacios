package com.reservas;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/CambiarEstadoTestimonioServlet")
public class CambiarEstadoTestimonioServlet extends HttpServlet {

    private TestimonioDAO dao = new TestimonioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String nuevoEstado = request.getParameter("estado"); // "Aprobado" o "Rechazado"

        dao.cambiarEstado(id, nuevoEstado);
        response.sendRedirect("TestimonioServlet?action=listar");
    }
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    // Leer parámetros de la URL
    String idParam = request.getParameter("id");
    String estadoParam = request.getParameter("estado");

    if (idParam != null && estadoParam != null) {
        int id = Integer.parseInt(idParam);
        dao.cambiarEstado(id, estadoParam);
    }

    // Redirigir de vuelta a la lista
    response.sendRedirect("TestimonioServlet?action=listar");
}

}
