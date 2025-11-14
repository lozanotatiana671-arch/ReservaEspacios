<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.reservas.Banner" %>
<%@ page import="java.util.*, com.reservas.RecursoDAO, com.reservas.Recurso, com.reservas.BannerDAO, com.reservas.Banner,  com.reservas.ReservaDAO, com.reservas.TestimonioDAO" %>

<%
    List<Banner> banners = new ArrayList<>();
    try {
        BannerDAO bdao = new BannerDAO();
        for (Banner b : bdao.listar()) {
            if (b.isActivo()) banners.add(b);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro de Usuario</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/slider.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilos.css">
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
        .btn-iniciar {
            background-color: #007bff;
            color: white;
        }
        .btn-iniciar:hover {
            background-color: #0056b3;
        }
        .card-form {
            max-width: 500px;
            margin: 40px auto;
            padding: 30px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,.1);
        }
        footer {
            background-color: #343a40;
        }
    </style>
</head>
<body>

    <%@ include file="navbarPublico.jsp" %>

    <!-- Slider dinámico -->
    <div id="slider" class="carousel slide mt-3" data-ride="carousel">
        <div class="carousel-inner">
            <%
                if (!banners.isEmpty()) {
                    int index = 0;
                    for (Banner b : banners) {
            %>
                        <div class="carousel-item <%= (index == 0 ? "active" : "") %>">
                            <img src="uploads/<%= b.getImagen() %>" class="d-block w-100" alt="<%= b.getTitulo() %>">
                            <div class="carousel-caption d-none d-md-block">
                                <h5><%= b.getTitulo() %></h5>
                            </div>
                        </div>
            <%
                        index++;
                    }
                } else {
            %>
                    <div class="carousel-item active">
                        <img src="img/slide1.jpg" class="d-block w-100" alt="Por defecto">
                    </div>
            <%
                }
            %>
        </div>
        <a class="carousel-control-prev" href="#slider" role="button" data-slide="prev">
            <span class="carousel-control-prev-icon"></span>
        </a>
        <a class="carousel-control-next" href="#slider" role="button" data-slide="next">
            <span class="carousel-control-next-icon"></span>
        </a>
    </div>

    <!-- 🔹 Formulario de registro -->
    <div class="card-form">
        <h2 class="text-center mb-4">Registro</h2>
        <form action="registro" method="post" autocomplete="off" autocapitalize="off" spellcheck="false">
    <div class="form-group">
        <label for="nombre">Nombre completo*</label>
        <input type="text" class="form-control" id="nombre" name="nombre" required autocomplete="off">
    </div>

    <div class="form-group">
        <label for="identificacion">Número identificación*</label>
        <input type="text" class="form-control" id="identificacion" name="identificacion" required autocomplete="off">
    </div>

    <div class="form-group">
        <label for="correo">Correo electrónico*</label>
        <input type="email" class="form-control" id="correo" name="correo" required autocomplete="off">
    </div>

    <div class="form-group">
        <label for="telefono">Número de teléfono*</label>
        <input type="text" class="form-control" id="telefono" name="telefono" required autocomplete="off">
    </div>

    <div class="form-group">
        <label for="password">Contraseña*</label>
        <input type="password" class="form-control" id="password" name="password" required autocomplete="new-password">
    </div>

    <div class="form-group">
        <label for="confirmar">Confirmar contraseña*</label>
        <input type="password" class="form-control" id="confirmar" name="confirmar" required autocomplete="new-password">
    </div>

    <button type="submit" class="btn btn-primary btn-block">Regístrate</button>
</form>


        <div class="text-center mt-3">
            <p>¿Ya tienes una cuenta? <a href="login.jsp">Ingresa aquí</a></p>
        </div>

        <!-- 🔹 Mensajes desde el servlet -->
        <p class="text-center mt-3" style="color:red;">
            <%= request.getAttribute("mensaje") != null ? request.getAttribute("mensaje") : "" %>
        </p>
    </div>


  <!-- 🔹 Footer -->
<footer class="text-white text-center p-3 mt-5 bg-dark">
  <p>&copy; 2025 Sistema de Reservas - Todos los derechos reservados</p>
</footer>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
