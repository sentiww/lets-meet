namespace LetsMeet.Persistence.Entities;


public class UserGroupEntity : BaseEntity
{


    public string Name { get; set; }

    public string Topic { get; set; }
    public int CreatedByUserId { get; set; }
    public UserEntity User { get; set; }

    public DateTime CreatedAt { get; set; }


}