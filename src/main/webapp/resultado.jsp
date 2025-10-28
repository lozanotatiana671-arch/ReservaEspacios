<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesion = request.getSession(false);
    String usuarioNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : null;
    String mensaje = (String) request.getAttribute("mensaje");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Resultado de la Reserva</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .navbar {
            background-color: #343a40;
        }
        .navbar-brand {
            font-weight: bold;
            color: #ffffff !important;
        }
        footer {
            background-color: #343a40;
            color: white;
        }
    </style>
</head>
<body>

    <!-- 🔹 Barra de navegación -->
    <nav class="navbar navbar-expand-lg">
        <a class="navbar-brand" href="index.jsp">ReservaEspacios</a>
        <div class="ml-auto">
            <% if (usuarioNombre != null) { %>
                <span class="text-white mr-3">👤 <%= usuarioNombre %></span>
                <a href="LogoutServlet" class="btn btn-danger btn-sm">Cerrar Sesión</a>
            <% } else { %>
                <a href="login.jsp" class="btn btn-primary btn-sm">Iniciar Sesión</a>
            <% } %>
        </div>
    </nav>

    <!-- 🔹 Contenido principal -->
    <div class="container mt-5">
        <h2 class="text-center mb-4">Resultado de la Reserva</h2>

        <% if (mensaje != null) {
            boolean esExito = mensaje.startsWith("✅") || mensaje.toLowerCase().contains("guardada");
        %>
            <div class="alert <%= esExito ? "alert-success" : "alert-danger" %> text-center" role="alert">
                <%= mensaje %>
            </div>
        <% } %>

        <div class="text-center mt-4">
            <a href="index.jsp" class="btn btn-primary">🏠 Volver al inicio</a>
            <% if (usuarioNombre != null) { %>
                <a href="MisReservasServlet" class="btn btn-info">📋 Ver mis reservas</a>
            <% } %>
        </div>
    </div>

    <!-- 🔹 Footer -->
    <footer class="text-center p-3 mt-5">
        <p>&copy; 2025 Sistema de Reservas - Todos los derechos reservados</p>
    </footer>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
