pub const State = enum {
    menu,
    game,
    end,
};

pub const Action = union(enum) {
    next,
    key: i32,
    update,
    reset,
    none,
};

pub const Model = struct {
    state: State,
    key: i32,
    updateFlag: bool,
    resetFlag: bool,

    pub fn handle(model: Model, action: Action) Model {
        var next = model;
        switch (action) {
            .next => next.state = switch (model.state) {
                .menu => .game,
                .game => .end,
                .end => return model.handle(.reset),
            },
            .key => |key| next.key = key,
            .update => next.updateFlag = true,
            .reset => {
                next.state = .menu;
                next.resetFlag = true;
            },
            .none => {},
        }
        return next;
    }
};
