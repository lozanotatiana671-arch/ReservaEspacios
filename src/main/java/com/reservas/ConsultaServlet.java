package com.reservas;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ConsultaServlet")
public class ConsultaServlet extends HttpServlet {

    // 🔹 Si alguien entra con GET, lo redirigimos al formulario
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("contactenos.jsp");
    }

    // 🔹 Procesa el formulario con POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Consulta c = new Consulta();
        c.setNombre(request.getParameter("nombre"));
        c.setCorreo(request.getParameter("correo"));
        c.setMensaje(request.getParameter("mensaje"));

        ConsultaDAO dao = new ConsultaDAO();
        boolean ok = dao.registrar(c);

        if (ok) {
            request.setAttribute("mensaje", "✅ Tu consulta fue enviada con éxito.");
        } else {
            request.setAttribute("mensaje", "❌ Error al enviar la consulta.");
        }

        request.getRequestDispatcher("contactenos.jsp").forward(request, response);
    }
}
