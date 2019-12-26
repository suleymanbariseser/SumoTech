using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Models
{
    public class GPU : Item
    {
        [Required]
        public string Chipset { get; set; }
        [Required]
        public int Memory { get; set; }
        [Required]
        public int Supplierid { get; set; }
    }
}