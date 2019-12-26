using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Models
{
    public class CPU : Item
    {
        [Required]
        public string Model { get; set; }
        [Required]
        public string CoreCount { get; set; }
        [Required]
        public int Supplierid { get; set; }
    }
}