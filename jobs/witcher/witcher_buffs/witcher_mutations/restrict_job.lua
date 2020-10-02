local RestrictBuff = class()

function RestrictBuff:_init()
end

-- entity is the entity that has this buff aplied
-- restrict_buff is the buff controller that contains the buff properties (json)
function RestrictBuff:on_buff_added(entity, restrict_buff)
   self._player_id = radiant.entities.get_player_id(entity)
   self._town = stonehearth.town:get_town(self._player_id)
   self._buff_data = restrict_buff._json.data

         -- Promote them to Worker and prevent promotion to other jobs
         self:restrict_jobs(entity, self._buff_data)

end

function RestrictBuff:restrict_jobs(entity, buff_data)
   local job = buff_data.restricted_job
   local jc = entity:add_component('stonehearth:job')
   jc:set_allowed_jobs(buff_data.allowed_jobs)
end


return RestrictBuff
