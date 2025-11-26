<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, com.reservas.RecursoDAO, com.reservas.Recurso, com.reservas.BannerDAO, com.reservas.Banner, com.reservas.ReservaDAO, com.reservas.TestimonioDAO" %>

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
    <title>Inicio de Sesión</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/slider.css">
            <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilos.css">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f8f9fa;
        }
        h2 {
            font-weight: 700;
        }
        .login-card {
            max-width: 420px;
            margin: 40px auto;
            padding: 30px;
            border-radius: 10px;
            background: #fff;
            box-shadow: 0 4px 12px rgba(0,0,0,.1);
        }
        .btn-custom {
            background-color: #007bff;
            color: #fff;
            font-weight: bold;
            text-transform: uppercase;
            border: none;
        }
        .btn-custom:hover {
            background-color: #0056b3;
        }
        footer {
            background: #e9ecef;
            padding: 15px;
            margin-top: 50px;
            font-size: 14px;
            color: #555;
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
                             <img src="<%= b.getImagen() %>" class="d-block w-100" alt="<%= b.getTitulo() %>">
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

    <!-- Formulario de inicio de sesión -->
    <div class="login-card">
        <h2 class="text-center mb-4">¡Iniciar Sesión!</h2>
        <form action="/login" method="post">
            <div class="form-group">
                <label>Correo electrónico*</label>
                <input type="email" name="correo" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Contraseña*</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-custom btn-block">INGRESAR</button>
        </form>

        <div class="text-center mt-3">
            <p>¿Aún no tienes una cuenta? <a href="registro.jsp">Regístrate aquí</a></p>
  
        </div>

        <p class="text-danger text-center">
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
