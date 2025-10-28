<%@ page contentType="text/html;charset=UTF-8" %>

<!-- 🔹 Navbar para usuario -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="index.jsp">ReservaEspacios</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" 
            data-target="#navbarNav" aria-controls="navbarNav" 
            aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                <a class="nav-link" href="MisReservasServlet">📋 Mis Reservas</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="perfilUsuario.jsp">👤 Mi Perfil</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="contactenos.jsp">✉️ Contáctenos</a>
            </li>
        </ul>

        <span class="navbar-text text-white mr-3">
            👤 <%= nombre %>
        </span>
        <a href="LogoutServlet" class="btn btn-danger btn-sm">Cerrar Sesión</a>
    </div>
</nav>
