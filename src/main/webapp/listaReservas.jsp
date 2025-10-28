<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Listado de Reservas</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
</head>
<%@ include file="navbarPrivado.jsp" %>

<body class="container mt-5">

    <h2>Listado de Reservas</h2>

    <table class="table table-bordered table-striped">
        <thead class="thead-dark">
            <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Fecha</th>
                <th>Hora</th>
                <th>Acciones</th> <!-- Nueva columna -->
            </tr>
        </thead>
        <tbody>
            <%
                List<String[]> reservas = (List<String[]>) request.getAttribute("reservas");
                if (reservas != null && !reservas.isEmpty()) {
                    for (String[] r : reservas) {
            %>
                        <tr>
                            <td><%= r[0] %></td>
                            <td><%= r[1] %></td>
                            <td><%= r[2] %></td>
                            <td><%= r[3] %></td>
                            <td>
                                <a href="EditarReservaServlet?id=<%= r[0] %>" class="btn btn-warning btn-sm">Editar</a>
                                <a href="EliminarReservaServlet?id=<%= r[0] %>" class="btn btn-danger btn-sm"
                                   onclick="return confirm('¿Seguro que deseas eliminar esta reserva?');">Eliminar</a>
                            </td>
                        </tr>
            <%
                    }
                } else {
            %>
                        <tr>
                            <td colspan="5" class="text-center">No hay reservas registradas</td>
                        </tr>
            <%
                }
            %>
        </tbody>
    </table>

    <a href="index.jsp" class="btn btn-primary">Nueva Reserva</a>

</body>
</html>
