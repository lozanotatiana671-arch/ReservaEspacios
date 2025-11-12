package com.reservas;

public class Testimonio {
    private int id;
    private int usuarioId;
    private String usuarioNombre;
    private String mensaje;
    private String estado;
    private String fecha;
    private String titulo;
    private int recursoId;  // ✅ antes estaba como idRecurso
    private int calificacion;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }

    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String usuarioNombre) { this.usuarioNombre = usuarioNombre; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public int getRecursoId() { return recursoId; }     // ✅ ahora coincide con DAO
    public void setRecursoId(int recursoId) { this.recursoId = recursoId; }

    public int getCalificacion() { return calificacion; }
    public void setCalificacion(int calificacion) { this.calificacion = calificacion; }
}
