<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, String>> contactos = (List<Map<String, String>>) request.getAttribute("contactos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mensajes de Contacto</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .navbar { background-color: #343a40; }
        .navbar-brand { font-weight: bold; color: #ffffff !important; }
        footer { background-color: #343a40; }
        .table td { vertical-align: middle; }
    </style>
</head>
<body>

    <!-- 🔹 Navbar -->
    <nav class="navbar navbar-expand-lg">
        <a class="navbar-brand" href="listaReservas.jsp">Panel Admin</a>
        <div class="ml-auto">
            <a href="LogoutServlet" class="btn btn-danger btn-sm">Cerrar Sesión</a>
        </div>
    </nav>

    <div class="container mt-5">
        <h2 class="text-center mb-4">📩 Mensajes de Contacto</h2>

        <table class="table table-bordered table-striped">
            <thead class="thead-dark">
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Mensaje</th>
                    <th>Fecha</th>
                    <th>Acciones</th> <!-- 🔹 Nueva columna -->
                </tr>
            </thead>
            <tbody>
                <%
                    if (contactos != null && !contactos.isEmpty()) {
                        for (Map<String, String> c : contactos) {
                %>
                            <tr>
                                <td><%= c.get("id") %></td>
                                <td><%= c.get("nombre") %></td>
                                <td><%= c.get("correo") %></td>
                                <td><%= c.get("mensaje") %></td>
                                <td><%= c.get("fecha") %></td>
                                <td>
                                    <form action="EliminarContactoServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="id" value="<%= c.get("id") %>">
                                        <button type="submit" class="btn btn-danger btn-sm"
                                                onclick="return confirm('¿Seguro que deseas eliminar este mensaje?');">
                                            🗑 Eliminar
                                        </button>
                                    </form>
                                </td>
                            </tr>
                <%
                        }
                    } else {
                %>
                            <tr>
                                <td colspan="6" class="text-center">No hay mensajes recibidos</td>
                            </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <div class="text-center">
            <a href="listaReservas.jsp" class="btn btn-secondary">⬅ Volver al panel</a>
        </div>
    </div>

    <!-- 🔹 Footer -->
    <footer class="text-white text-center p-3 mt-5">
        <p>&copy; 2025 Sistema de Reservas - Todos los derechos reservados</p>
    </footer>

</body>
</html>
