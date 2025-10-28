package com.reservas;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) action = "listar";

        switch (action) {
            case "nuevo":
                request.getRequestDispatcher("usuarioForm.jsp").forward(request, response);
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Usuario usuario = usuarioDAO.obtenerPorId(idEditar);
                request.setAttribute("usuario", usuario);
                request.getRequestDispatcher("usuarioForm.jsp").forward(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                usuarioDAO.eliminar(idEliminar);
                response.sendRedirect("UsuarioServlet?action=listar");
                break;
                
            case "buscar":
                 String criterio = request.getParameter("criterio");
                 List<Usuario> resultados = usuarioDAO.buscar(criterio);
                 request.setAttribute("usuarios", resultados);
                 request.setAttribute("criterio", criterio);
                 request.getRequestDispatcher("usuarios.jsp").forward(request, response);
                 break;


            case "listar":
            default:
                List<Usuario> lista = usuarioDAO.listar();
                request.setAttribute("usuarios", lista);
                request.getRequestDispatcher("usuarios.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                ? Integer.parseInt(request.getParameter("id"))
                : 0;

        String nombre = request.getParameter("nombre");
        String identificacion = request.getParameter("identificacion");
        String correo = request.getParameter("correo");
        String telefono = request.getParameter("telefono");
        String password = request.getParameter("password");
        String rol = request.getParameter("rol");

        Usuario u = new Usuario();
        u.setId(id);
        u.setNombre(nombre);
        u.setIdentificacion(identificacion);
        u.setCorreo(correo);
        u.setTelefono(telefono);
        u.setPassword(password);
        u.setRol(rol);

        if (id == 0) {
            usuarioDAO.registrar(u);
        } else {
            usuarioDAO.actualizar(u);
        }

        response.sendRedirect("UsuarioServlet?action=listar");
    }
}
