using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Models
{
    public class BasicElectronic : Item
    {
        [Required]
        public string ElectronicType { get; set; }
        [Required]
        public int Supplierid { get; set; }
    }
}