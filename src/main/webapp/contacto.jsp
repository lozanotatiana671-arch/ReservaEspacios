<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Contacto</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
</head>
<body>
<div class="container mt-5">
    <h2>📨 Envíanos tu consulta</h2>
    <form action="ConsultaServlet" method="post">
        <div class="form-group">
            <label>Nombre</label>
            <input type="text" name="nombre" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Correo</label>
            <input type="email" name="correo" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Mensaje</label>
            <textarea name="mensaje" class="form-control" rows="4" required></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Enviar Consulta</button>
    </form>

    <% if (request.getAttribute("msg") != null) { %>
        <div class="alert alert-info mt-3">
            <%= request.getAttribute("msg") %>
        </div>
    <% } %>
</div>
</body>
</html>
