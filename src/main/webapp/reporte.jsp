<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>

<%!
    public String v(Object o) { return (o == null) ? "" : o.toString(); }
%>

<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String adminNombre = (String) sesion.getAttribute("usuarioNombre");
    if (adminNombre == null) adminNombre = "Admin";

    Map<String,Integer> reservasPorEstado = (Map<String,Integer>) request.getAttribute("reservasPorEstado");
    Map<String,Integer> reservasPorRecurso = (Map<String,Integer>) request.getAttribute("reservasPorRecurso");
    Map<String,Integer> reservasPorTipo = (Map<String,Integer>) request.getAttribute("reservasPorTipo");
    List<Map<String,Object>> listaRecursos = (List<Map<String,Object>>) request.getAttribute("listaRecursos");

    if (reservasPorEstado == null) reservasPorEstado = new LinkedHashMap<>();
    if (reservasPorRecurso == null) reservasPorRecurso = new LinkedHashMap<>();
    if (reservasPorTipo == null) reservasPorTipo = new LinkedHashMap<>();
    if (listaRecursos == null) listaRecursos = new ArrayList<>();

    boolean sinFiltros =
        v(request.getAttribute("fechaInicio")).isEmpty() &&
        v(request.getAttribute("fechaFin")).isEmpty() &&
        v(request.getAttribute("tipoEspacio")).isEmpty() &&
        v(request.getAttribute("estadoRecurso")).isEmpty();
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Dashboard - Reportes</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
/* --- DISEÑO DASHBOARD --- */
.chart-card {
    background: white;
    border-radius: 16px;
    padding: 20px;
    margin-bottom: 25px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    text-align:center;
    border:1px solid #e8e8e8;
}
.chart-title { font-weight:700; color:#00482B; }

/* Tamaño de gráficos */
.chart-small-container { height:180px; }
.chart-small-container canvas { max-height:160px !important; }

/* Leyendas estilo A */
.leyenda { margin-top:8px; text-align:left; font-size:13px; }
.leyenda span.color {
    display:inline-block;
    width:14px; height:14px;
    border-radius:3px;
    margin-right:6px;
}

/* Tabla y hover */
table thead { background:#00482B; color:white; }

/* Filtro tabla */
.filtro-tabla {
    margin-top: 25px;
    margin-bottom: 10px;
}

/* Paginación centrada */
.pagination-container {
    text-align:center;
    margin-top:20px;
}
.pagination button {
    margin:3px;
    padding:6px 14px;
    border:none;
    border-radius:5px;
    background:#00482B;
    color:white;
}
.pagination button.active { background:#79C000; }

</style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="ListaReservasServlet">SistemaReserva</a>
    <button class="navbar-toggler" data-toggle="collapse" data-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item"><a class="nav-link" href="ListaReservasServlet">📋 Reservas</a></li>
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet">⚙️ Recursos</a></li>
            <li class="nav-item"><a class="nav-link" href="UsuarioServlet?action=listar">👤 Usuarios</a></li>
            <li class="nav-item"><a class="nav-link active" href="ReporteServlet">📊 Reportes</a></li>
        </ul>
        <span class="navbar-text text-white mr-3">👤 <%= adminNombre %></span>
        <a href="LogoutServlet" class="btn btn-sm btn-outline-light">Cerrar Sesión</a>
    </div>
</nav>

<div class="container-fluid">
<div class="row">

<!-- SIDEBAR -->
<nav class="col-md-2 side-menu" id="sideMenu">
    <h4><i class="fas fa-cogs"></i> Administración</h4>
    <a href="UsuarioServlet?action=listar"><i class="fas fa-users"></i> Usuarios</a>
    <a href="configuracion.jsp"><i class="fas fa-cog"></i> Configuración</a>
    <a href="BannerServlet"><i class="fas fa-image"></i> Banner</a>
    <hr>
    <a href="ListaReservasServlet"><i class="fas fa-calendar-check"></i> Gestionar Reservas</a>
    <a href="TestimonioServlet?action=listar"><i class="fas fa-comment-alt"></i> Gestionar Testimonios</a>
    <a href="ListaConsultasServlet?action=listar"><i class="fas fa-envelope"></i> Gestionar Consultas</a>
    <hr>
    <a href="nuevoRecurso.jsp"><i class="fas fa-plus-circle"></i> Nuevo Espacio</a>
    <a href="ListaRecursosServlet?action=listar"><i class="fas fa-building"></i> Gestionar Espacios</a>
    <a href="ReporteServlet" class="active"><i class="fas fa-chart-bar"></i> Reportes</a>
</nav>

<!-- CONTENIDO -->
<main class="col-md-10 content-area">

<h2 class="mt-3 mb-4 text-success">📊 Dashboard de Reportes</h2>

<!-- FILTROS GLOBALES -->
<form action="ReporteServlet" method="get" id="formFiltros">

<div class="form-row">
    <div class="col-md-3">
        <label>Fecha Inicio</label>
        <input type="date" name="fechaInicio" class="form-control"
               value="<%= v(request.getAttribute("fechaInicio")) %>">
    </div>

    <div class="col-md-3">
        <label>Fecha Fin</label>
        <input type="date" name="fechaFin" class="form-control"
               value="<%= v(request.getAttribute("fechaFin")) %>">
    </div>

    <div class="col-md-3">
        <label>Tipo</label>
        <select name="tipoEspacio" class="form-control">
            <option value="">Todos</option>
            <option value="SALON">Salón</option>
            <option value="LABORATORIO">Laboratorio</option>
            <option value="EQUIPO">Equipo</option>
        </select>
    </div>

    <div class="col-md-3">
        <label>Estado</label>
        <select name="estadoRecurso" class="form-control">
            <option value="">Todos</option>
            <option value="ACTIVO">Activo</option>
            <option value="INACTIVO">Inactivo</option>
        </select>
    </div>
</div>

<!-- BOTONES PDF / EXCEL -->
<div class="mt-3 text-right">
    <button class="btn btn-success"><i class="fas fa-search"></i> Generar</button>

    <a class="btn btn-danger"
       href="ReporteExportServlet?tipo=pdf&fechaInicio=<%=v(request.getAttribute("fechaInicio"))%>&fechaFin=<%=v(request.getAttribute("fechaFin"))%>&tipo=<%=v(request.getAttribute("tipoEspacio"))%>&estado=<%=v(request.getAttribute("estadoRecurso"))%>">
       <i class="fas fa-file-pdf"></i> PDF
    </a>

    <a class="btn btn-primary"
       href="ReporteExportServlet?tipo=excel&fechaInicio=<%=v(request.getAttribute("fechaInicio"))%>&fechaFin=<%=v(request.getAttribute("fechaFin"))%>&tipo=<%=v(request.getAttribute("tipoEspacio"))%>&estado=<%=v(request.getAttribute("estadoRecurso"))%>">
       <i class="fas fa-file-excel"></i> Excel
    </a>
</div>

</form>

<% if (sinFiltros) { %>

<div class="mensaje-central text-center mt-5">
    <i class="fas fa-info-circle" style="font-size:55px; color:#00482B;"></i>
    <h4 style="color:#00482B;">Selecciona un filtro para generar reportes</h4>
</div>

<% } else { %>

<!-- DASHBOARD -->
<div class="row">

<!-- ESTADO -->
<div class="col-md-4">
<div class="chart-card">
    <div class="chart-title">Distribución por Estado</div>
    <div class="chart-small-container">
        <canvas id="chartEstado"></canvas>
    </div>

    <div class="leyenda">
        <% for (String key : reservasPorEstado.keySet()) { %>
            <div><span class="color" style="background:#79C000;"></span> <%= key %>: <%= reservasPorEstado.get(key) %></div>
        <% } %>
    </div>
</div>
</div>

<!-- RECURSO -->
<div class="col-md-4">
<div class="chart-card">
    <div class="chart-title">Cantidad por Recurso</div>
    <div class="chart-small-container">
        <canvas id="chartRecurso"></canvas>
    </div>

    <div class="leyenda">
        <% for (String key : reservasPorRecurso.keySet()) { %>
            <div><span class="color" style="background:#007B3E;"></span> <%= key %>: <%= reservasPorRecurso.get(key) %></div>
        <% } %>
    </div>
</div>
</div>

<!-- TIPO -->
<div class="col-md-4">
<div class="chart-card">
    <div class="chart-title">Distribución por Tipo</div>
    <div class="chart-small-container">
        <canvas id="chartTipo"></canvas>
    </div>

    <div class="leyenda">
        <% for (String key : reservasPorTipo.keySet()) { %>
            <div><span class="color" style="background:#1F77B4;"></span> <%= key %>: <%= reservasPorTipo.get(key) %></div>
        <% } %>
    </div>
</div>
</div>

</div>

<!-- FILTRO TABLA -->
<div class="filtro-tabla">
<label><b>Buscar:</b></label>
<input type="text" id="buscarTabla" class="form-control" placeholder="Filtrar resultados...">
</div>

<!-- TABLA -->
<table id="tablaRecursos" class="table table-bordered mt-3">
<thead>
<tr>
    <th>Nombre</th>
    <th>Tipo</th>
    <th>Estado</th>
    <th>Tarifa (COP)</th>
    <th>Ubicación</th>
</tr>
</thead>
<tbody>
<% for (Map<String,Object> fila : listaRecursos) { %>
<tr>
    <td><%= fila.get("nombre") %></td>
    <td><%= fila.get("tipo") %></td>
    <td><%= fila.get("estado") %></td>
    <td><%= fila.get("tarifa") %></td>
    <td><%= fila.get("ubicacion") %></td>
</tr>
<% } %>
</tbody>
</table>

<!-- PAGINACIÓN -->
<div class="pagination-container">
    <button id="prevPage">Anterior</button>
    <span id="pagination"></span>
    <button id="nextPage">Siguiente</button>
</div>

<% } %>

</main>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
/* COLORES CORPORATIVOS */
const verde = "#007B3E";
const verdeClaro = "#79C000";
const azul = "#1F77B4";
const amarillo = "#FBE122";
const rojo = "#DC3545";

/* ====== GRAFICO ESTADO ====== */
const labelsEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.keySet()) %>;
const dataEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.values()) %>;

if (labelsEstado.length > 0) {
new Chart(document.getElementById('chartEstado'), {
    type: 'doughnut',
    data: {
        labels: labelsEstado,
        datasets: [{
            data: dataEstado,
            backgroundColor: [verdeClaro, azul, amarillo, rojo],
            borderWidth: 0
        }]
    },
    options: { cutout: "65%", plugins:{legend:{display:false}} }
});
}

/* ====== GRAFICO RECURSO ====== */
const labelsRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.keySet()) %>;
const dataRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.values()) %>;

if (labelsRecurso.length > 0) {
new Chart(document.getElementById('chartRecurso'), {
    type: 'bar',
    data: {
        labels: labelsRecurso,
        datasets: [{
            data: dataRecurso,
            backgroundColor: verde,
            borderRadius: 12,
            barThickness: 28
        }]
    },
    options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
});
}

/* ====== GRAFICO TIPO ====== */
const labelsTipo = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.keySet()) %>;
const dataTipo = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.values()) %>;

if (labelsTipo.length > 0) {
new Chart(document.getElementById('chartTipo'), {
    type: 'pie',
    data: {
        labels: labelsTipo,
        datasets: [{
            data: dataTipo,
            backgroundColor: [verdeClaro, azul, amarillo, verde],
            borderWidth: 0
        }]
    },
    options: { plugins:{legend:{display:false}} }
});
}

/* ===== FILTRAR TABLA ===== */
document.getElementById("buscarTabla").addEventListener("keyup", function() {
    const value = this.value.toLowerCase();
    document.querySelectorAll("#tablaRecursos tbody tr").forEach(tr => {
        tr.style.display = tr.innerText.toLowerCase().includes(value) ? "" : "none";
    });
});

/* ===== PAGINACIÓN ===== */
const rowsPerPage = 2;
const table = document.getElementById("tablaRecursos");

if (table) {
const rows = table.querySelectorAll("tbody tr");
const pageCount = Math.ceil(rows.length / rowsPerPage);
const paginationSpan = document.getElementById("pagination");

let currentPage = 1;

function renderPage(page) {
    rows.forEach((row, index) => {
        row.style.display = (index >= (page-1)*rowsPerPage && index < page*rowsPerPage) ? "" : "none";
    });

    paginationSpan.innerHTML = "";

    for (let i = 1; i <= pageCount; i++) {
        let btn = document.createElement("button");
        btn.innerText = i;
        btn.className = (i === page) ? "active" : "";
        btn.onclick = () => { currentPage = i; renderPage(i); };
        paginationSpan.appendChild(btn);
    }
}

document.getElementById("prevPage").onclick = () => {
    if (currentPage > 1) { currentPage--; renderPage(currentPage); }
};
document.getElementById("nextPage").onclick = () => {
    if (currentPage < pageCount) { currentPage++; renderPage(currentPage); }
};

renderPage(1);
}

/* ===== AUTO-FILTRAR ===== */
document.querySelectorAll("#formFiltros input, #formFiltros select")
    .forEach(el => el.addEventListener("change", () => document.getElementById("formFiltros").submit()));
</script>

</body>
</html>
