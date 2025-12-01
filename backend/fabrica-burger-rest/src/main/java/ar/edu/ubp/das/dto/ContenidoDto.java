package ar.edu.ubp.das.dto;

public class ContenidoDto {
    private String nroContenido;
    private boolean exitoso;
    private String mensaje;

    public String getNroContenido() {
        return nroContenido;
    }

    public void setNroContenido(String nroContenido) {
        this.nroContenido = nroContenido;
    }

    public boolean isExitoso() {
        return exitoso;
    }

    public void setExitoso(boolean exitoso) {
        this.exitoso = exitoso;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }
}

