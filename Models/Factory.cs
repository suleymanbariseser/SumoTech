using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Factory
    {
        [Required]
        [Key]
        public int Id { get; set; }
        [Required]
        public String Country { get; set; }
        [Required]
        public String City { get; set; }
        [Required]
        public String Address { get; set; }
        [Required]
        public int Capacity { get; set; }
        public List<HouseHold> List { get; set; }
    }
}