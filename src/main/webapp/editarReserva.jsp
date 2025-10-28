<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Editar Reserva</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-5">

    <h2>Editar Reserva</h2>

    <form action="EditarReservaServlet" method="post">
        <input type="hidden" name="id" value="${id}">

        <div class="form-group">
            <label>Nombre</label>
            <input type="text" class="form-control" name="nombre" value="${nombre}" required>
        </div>

        <div class="form-group">
            <label>Fecha</label>
            <input type="date" class="form-control" name="fecha" value="${fecha}" required>
        </div>

        <div class="form-group">
            <label>Hora</label>
            <input type="text" class="form-control" name="hora" value="${hora}" required>
        </div>

        <button type="submit" class="btn btn-success">Actualizar</button>
        <a href="ListaReservasServlet" class="btn btn-secondary">Cancelar</a>
    </form>

</body>
</html>
