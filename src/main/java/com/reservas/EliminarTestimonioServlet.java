package com.reservas;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/EliminarTestimonioServlet")
public class EliminarTestimonioServlet extends HttpServlet {

    private TestimonioDAO dao = new TestimonioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                dao.eliminar(id);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // Redirige a la lista de testimonios
        response.sendRedirect("TestimonioServlet?action=listar");
    }
}
