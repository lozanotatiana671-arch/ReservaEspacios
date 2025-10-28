<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, com.reservas.Notificacion" %>
<!DOCTYPE html>
<html>
<head>
    <title>Notificaciones</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-5">

<h2>Notificaciones</h2>

<table class="table table-bordered table-striped">
    <thead class="thead-dark">
        <tr>
            <th>ID</th>
            <th>Mensaje</th>
            <th>Estado</th>
            <th>Fecha</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <%
            List<Notificacion> notificaciones = (List<Notificacion>) request.getAttribute("notificaciones");
            if (notificaciones != null && !notificaciones.isEmpty()) {
                for (Notificacion n : notificaciones) {
        %>
            <tr>
                <td><%= n.getId() %></td>
                <td><%= n.getMensaje() %></td>
                <td><%= n.getEstado() %></td>
                <td><%= n.getFecha() %></td>
                <td>
                    <a href="MarcarLeidaServlet?id=<%= n.getId() %>"
                       class="btn btn-success btn-sm">Marcar como leída</a>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="5" class="text-center">No hay notificaciones</td>
            </tr>
        <%
            }
        %>
    </tbody>
</table>

<a href="index.jsp" class="btn btn-primary">Volver</a>

</body>
</html>
