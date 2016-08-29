module ChildUpdate exposing (updateOne, updateMany)

{-| Delegates update messages to a child. Given a one-to-one parent to child
relationship as follows:

    type alias Model =
        { widget : Widget.Model
        }

    setWidget : Model -> Widget.Model -> Model
    setWidget model =
        \x -> { model | widget = x }

    type Msg
        = WidgetMessage Widget.Msg

Use `Child.update` to delegate updates to the child `update` function:

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        WidgetMessage cMsg->
            Child.update WidgetMessage .widget setWidget Widget.update cMsg model
-}


updateOne :
    (childMsg -> msg)
    -> (model -> childModel)
    -> (model -> childModel -> model)
    -> (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> childMsg
    -> model
    -> ( model, Cmd msg )
updateOne msgMap getter setter childUpdate childMsg model =
    let
        ( newChild, childCmd ) =
            childUpdate childMsg (getter model)
    in
        ( setter model newChild, Cmd.map msgMap childCmd )


updateMany :
    (childId -> childMsg -> msg)
    -> (model -> List childModel)
    -> (model -> List childModel -> model)
    -> (childModel -> childId)
    -> (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> childId
    -> childMsg
    -> model
    -> ( model, Cmd msg )
updateMany msgMap getter setter getId childUpdate childId childMsg model =
    let
        ( newChildren, childCmd ) =
            (getter model)
                |> updateManyChildren childUpdate getId childId childMsg
    in
        ( (setter model newChildren), Cmd.map (msgMap childId) childCmd )


updateManyChildren :
    (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> (childModel -> childId)
    -> childId
    -> childMsg
    -> List childModel
    -> ( List childModel, Cmd childMsg )
updateManyChildren childUpdate getId id msg children =
    let
        ( newChildren, cmds ) =
            children
                |> List.map (updateOneChildOfMany childUpdate getId id msg)
                |> List.unzip
    in
        ( newChildren, Cmd.batch cmds )


updateOneChildOfMany :
    (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> (childModel -> childId)
    -> childId
    -> childMsg
    -> childModel
    -> ( childModel, Cmd childMsg )
updateOneChildOfMany childUpdate getId id msg child =
    let
        ( newChild, cmd ) =
            if (getId child) == id then
                childUpdate msg child
            else
                ( child, Cmd.none )
    in
        ( newChild, cmd )
