
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Back_End.Models
{
    public class FormCrearNotificacion
    {
        [Required]
        public string Descripcion { get; set; }

        [Required]
        public string FechaNotificacion { get; set; } 
        
    }
}