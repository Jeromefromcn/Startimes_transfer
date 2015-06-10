select p.resourcecodestr from phyresourceen p group by p.resourcecodestr having count(*) > 1
