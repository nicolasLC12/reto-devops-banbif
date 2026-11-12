package pe.banbif.reto.reto_examen;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController 
public class SaludoCon {
    
    @GetMapping("/hola")
    public Map<String, String> obtenerSaludo(){

        String mensaje = "Hola Mundo desde BanBif";
        String estado = "correcto";

        String aplicacion = "reto-examen";

        return Map.of(

            "mensaje", mensaje,
            "estado", estado,
            "aplicacion", aplicacion
        );
    }
    
}
