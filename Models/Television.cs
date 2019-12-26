using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Models
{
    public class Television : Item
    {
        [Required]
        public double ScreenSize { get; set; }
        [Required]
        public string ScreenResolution { get; set; }
        [Required]
        public bool IsSmart { get; set; }
        [Required]
        public int Supplierid { get; set; }
    }
}